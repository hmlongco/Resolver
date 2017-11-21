//
// Resolver.swift
//
// Copyright © 2017 Michael Long. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

import Foundation

public protocol ResolverRegistering {
    static func registerAllServices()
}

public protocol Resolving {
    var resolver: Resolver { get }
}

public final class Resolver {

    public static var main: Resolver = Resolver()               // default Resolver registry
    public static var defaultScope = Resolver.graph             // default scope used when registering new objects

    public let args: Any?

    public init(parent: Resolver? = nil) {
        self.parent = parent
        self.registrations = [:]
        self.args = nil
    }

    fileprivate init(parent: Resolver, args: Any?) {
        self.parent = parent
        self.registrations = nil
        self.args = args
    }

    @discardableResult
    public func register<Service>(_ type: Service.Type = Service.self, name: String? = nil,
                                  factory: @escaping ResolverFactory<Service>) -> ResolverOptions<Service> {
        let registration = ResolverRegistration(resolver: self, key: generateKey(type, name), factory: factory)
        registrations?[registration.key] = registration
        return registration
    }

    public func resolve<Service>(_ type: Service.Type = Service.self, name: String? = nil) -> Service {
        if let registration = lookup(type, name: name), let service = registration.scope.resolve(resolver: self, registration: registration) {
            return service
        }
        fatalError("RESOLVER: '\(Service.self):\(name ?? "")' not resolved")
    }

    public func resolve<Service>(_ type: Service.Type = Service.self, name: String? = nil, args: Any) -> Service {
        if let registration = lookup(type, name: name),
            let service = registration.scope.resolve(resolver: Resolver(parent: self, args: args), registration: registration) {
            return service
        }
        fatalError("RESOLVER: '\(Service.self):\(name ?? "")' not resolved")
    }

    public func optional<Service>(_ type: Service.Type = Service.self, name: String? = nil) -> Service? {
        if let registration = lookup(type, name: name), let service = registration.scope.resolve(resolver: self, registration: registration) {
            return service
        }
        return nil
    }

    public func optional<Service>(_ type: Service.Type = Service.self, name: String? = nil, args: Any) -> Service? {
        if let registration = lookup(type, name: name),
            let service = registration.scope.resolve(resolver: Resolver(parent: self, args: args), registration: registration) {
            return service
        }
        return nil
    }

    private func lookup<Service>(_ type: Service.Type, name: String?) -> ResolverRegistration<Service>? {
        if let registrations = registrations, let registration = registrations[generateKey(type, name)] as? ResolverRegistration<Service> {
            return registration
        }
        if let parent = parent, let registration = parent.lookup(type, name: name) {
            return registration
        }
        if let _ = name, parent == nil {
            return lookup(type, name: nil) // attempt resolution without name
        }
        return nil
    }

    private func generateKey<Service>(_ type: Service.Type, _ name: String?) -> String {
        if let name = name {
            return String(describing: type) + ":" + name
        }
        return String(describing: type)
    }

    private let parent: Resolver?
    private var registrations: [String : Any]?
}

// Registration Internals

public typealias ResolverFactory<Service> = (_ resolver: Resolver) -> Service?
public typealias ResolverFactoryMutator<Service> = (_ resolver: Resolver, _ service: Service) -> Void

public class ResolverOptions<Service> {

    var scope: ResolverScope

    fileprivate var factory: ResolverFactory<Service>
    fileprivate var mutator: ResolverFactoryMutator<Service>?
    fileprivate weak var resolver: Resolver?

    public init(resolver: Resolver, factory: @escaping ResolverFactory<Service>) {
        self.factory = factory
        self.resolver = resolver
        self.scope = Resolver.defaultScope
    }

    @discardableResult
    public func implements<Protocol>(_ type: Protocol.Type, name: String? = nil) -> ResolverOptions<Service> {
        resolver?.register(type.self, name: name) { r in r.resolve(Service.self) as? Protocol }
        return self
    }

    @discardableResult
    public func resolveProperties(_ block: @escaping ResolverFactoryMutator<Service>) -> ResolverOptions<Service> {
        mutator = block
        return self
    }

    @discardableResult
    public func scope(_ scope: ResolverScope) -> ResolverOptions<Service> {
        self.scope = scope
        return self
    }

}

public final class ResolverRegistration<Service>: ResolverOptions<Service> {

    public var key: String

    public init(resolver: Resolver, key: String, factory: @escaping ResolverFactory<Service>) {
        self.key = key
        super.init(resolver: resolver, factory: factory)
    }

    public func resolve(resolver: Resolver) -> Service? {
        if let service = factory(resolver)  {
            self.mutator?(resolver, service)
            return service
        }
        return nil
    }
}

// Scopes

extension Resolver {

    // All application scoped services exist for lifetime of the app. (e.g Singletons)
    public static let application = ResolverScopeCache()

    // Cached services exist for lifetime of the app or until their cache is reset.
    public static let cached = ResolverScopeCache()

    // Graph services are initialized once and only once during a given resolution cycle. This is the default scope.
    public static let graph = ResolverScopeGraph()

    // Shared services persist while strong references to them exist. They're then deallocated until the next resolve.
    public static let shared = ResolverScopeShare()

    // Unique services are created and initialized each and every time they're resolved.
    public static let unique = ResolverScopeUnique()

}

public protocol ResolverScope: class {
    func resolve<Service>(resolver: Resolver, registration: ResolverRegistration<Service>) -> Service?
}

public final class ResolverScopeCache: ResolverScope {

    public func resolve<Service>(resolver: Resolver, registration: ResolverRegistration<Service>) -> Service? {
        pthread_mutex_lock(&mutex)
        if let service = cachedServices[registration.key] as? Service {
            pthread_mutex_unlock(&mutex)
            return service
        }
        if let service = registration.resolve(resolver: resolver) {
            cachedServices[registration.key] = service
            pthread_mutex_unlock(&mutex)
            return service
        }
        pthread_mutex_unlock(&mutex)
        return nil
    }

    public func reset() {
        pthread_mutex_lock(&mutex)
        cachedServices.removeAll()
        pthread_mutex_unlock(&mutex)
    }

    private var cachedServices = [String : Any](minimumCapacity: 32)
    private var mutex = pthread_mutex_t()
}

public final class ResolverScopeGraph: ResolverScope {

    public func resolve<Service>(resolver: Resolver, registration: ResolverRegistration<Service>) -> Service? {
        pthread_mutex_lock(&mutex)
        if let service = graph[registration.key] as? Service {
            pthread_mutex_unlock(&mutex)
            return service
        }
        resolutionDepth = resolutionDepth + 1
        let service = registration.resolve(resolver: resolver)
        resolutionDepth = resolutionDepth - 1
        if resolutionDepth == 0 {
            graph.removeAll()
        } else {
            graph[registration.key] = service
        }
        pthread_mutex_unlock(&mutex)
        return service
    }

    private var graph = [String : Any?](minimumCapacity: 32)
    private var resolutionDepth: Int = 0
    private var mutex = pthread_mutex_t()
}

public final class ResolverScopeShare: ResolverScope {

    public func resolve<Service>(resolver: Resolver, registration: ResolverRegistration<Service>) -> Service? {
        pthread_mutex_lock(&mutex)
        if let service = cachedServices[registration.key] as? Service {
            pthread_mutex_unlock(&mutex)
            return service
        }
        if let service = registration.resolve(resolver: resolver) {
            if type(of:service) is AnyClass {
                cachedServices[registration.key] = BoxWeak(service: service as AnyObject)
            } else {
                fatalError("RESOLVER: '\(registration.key)' not a class/reference type")
            }
            pthread_mutex_unlock(&mutex)
            return service
        }
        pthread_mutex_unlock(&mutex)
        return nil
    }

    struct BoxWeak {
        weak var service: AnyObject?
    }

    private var cachedServices = [String : BoxWeak](minimumCapacity: 32)
    private var mutex = pthread_mutex_t()
}

public final class ResolverScopeUnique: ResolverScope {

    public func resolve<Service>(resolver: Resolver, registration: ResolverRegistration<Service>) -> Service? {
        return registration.resolve(resolver: resolver)
    }

}

// Root resolver and automatic registration resolution

extension Resolver {

    public static var root: Resolver {
        get {
            if Resolver.servicesRegistered == false {
                Resolver.registerServices()
            }
            return currentRoot
        }
        set {
            currentRoot = newValue
        }
    }

    static func registerServices() {
        guard Resolver.servicesRegistered == false else {
            return
        }
        Resolver.servicesRegistered = true
        if let registering = (Resolver.main as Any) as? ResolverRegistering {
            type(of: registering).registerAllServices()
        }
    }

    private static var currentRoot: Resolver = main
    private static var servicesRegistered = false
}

extension Resolving {
    public var resolver: Resolver {
        return Resolver.root
    }
}

