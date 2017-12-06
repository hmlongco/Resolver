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

extension Resolving {
    public var resolver: Resolver {
        return Resolver.root
    }
}
public final class Resolver {

    public static let main: Resolver = Resolver()               // default Resolver registry
    public static var root: Resolver = main                     // default root registry used by Resolving protocol
    public static var defaultScope = Resolver.graph             // default scope used when registering new objects

    public let args: Any?

    // MARK: - Resolver - Lifecycle

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

    // MARK: - Resolver - Registration

    public final func registerServices() {
        guard Resolver.registrationsNeeded else {
            return
        }
        Resolver.registrationsNeeded = false
        if let registering = (Resolver.main as Any) as? ResolverRegistering {
            type(of: registering).registerAllServices()
        }
    }

    @discardableResult
    public final func register<Service>(_ type: Service.Type = Service.self, name: String? = nil,
                                        factory: @escaping ResolverFactory<Service>) -> ResolverOptions<Service> {
        return register(type, name: name, factory: { (_) -> Service? in return factory() })
    }

    @discardableResult
    public final func register<Service>(_ type: Service.Type = Service.self, name: String? = nil,
                                        factory: @escaping ResolverFactoryArguments<Service>) -> ResolverOptions<Service> {
        let key = ObjectIdentifier(Service.self).hashValue
        if let name = name {
            let registration = ResolverRegistration(resolver: self, key: key, factory: factory)
            if let container = registrations?[key] as? ResolverRegistration<Service> {
                container.addRegistration(name, registration: registration)
            } else {
                let container = ResolverRegistration(resolver: self, key: key, factory: factory)
                container.addRegistration(name, registration: registration)
                registrations?[key] = container
            }
            return registration
        } else if let registration = registrations?[key] as? ResolverRegistration<Service> {
            registration.factory = factory
            return registration
        } else {
            let registration = ResolverRegistration(resolver: self, key: key, factory: factory)
            registrations?[key] = registration
            return registration
        }
    }

    // MARK: - Resolver - Resolution

    static func resolve<Service>(name: String? = nil) -> Service {
        return root.resolve(Service.self, name: name)
    }

    public final func resolve<Service>(_ type: Service.Type = Service.self, name: String? = nil) -> Service {
        if let registration = lookup(type, name: name), let service = registration.scope.resolve(resolver: self, registration: registration) {
            return service
        }
        fatalError("RESOLVER: '\(Service.self):\(name ?? "")' not resolved")
    }

    public final func resolve<Service>(_ type: Service.Type = Service.self, name: String? = nil, args: Any) -> Service {
        if let registration = lookup(type, name: name),
            let service = registration.scope.resolve(resolver: Resolver(parent: self, args: args), registration: registration) {
            return service
        }
        fatalError("RESOLVER: '\(Service.self):\(name ?? "")' not resolved")
    }

    static func optional<Service>(name: String? = nil) -> Service? {
        return root.optional(Service.self, name: name)
    }

    public final func optional<Service>(_ type: Service.Type = Service.self, name: String? = nil) -> Service? {
        if let registration = lookup(type, name: name), let service = registration.scope.resolve(resolver: self, registration: registration) {
            return service
        }
        return nil
    }

    public final func optional<Service>(_ type: Service.Type = Service.self, name: String? = nil, args: Any) -> Service? {
        if let registration = lookup(type, name: name),
            let service = registration.scope.resolve(resolver: Resolver(parent: self, args: args), registration: registration) {
            return service
        }
        return nil
    }

    // MARK: - Resolver - Internal

    private final func lookup<Service>(_ type: Service.Type, name: String?) -> ResolverRegistration<Service>? {
        if Resolver.registrationsNeeded {
            registerServices()
        }
        if let registrations = registrations,
            let registration = registrations[ObjectIdentifier(Service.self).hashValue] as? ResolverRegistration<Service> {
            if let name = name {
                if let registration = registration.namedRegistrations?[name] as? ResolverRegistration<Service> {
                    return registration
                }
            } else {
                return registration
            }
        }
        if let parent = parent, let registration = parent.lookup(type, name: name) {
            return registration
        }
        return nil
    }

    private let parent: Resolver?
    private var registrations: [Int : Any]?
    private static var registrationsNeeded = true
}

// Registration Internals

public typealias ResolverFactory<Service> = () -> Service?
public typealias ResolverFactoryArguments<Service> = (_ resolver: Resolver) -> Service?
public typealias ResolverFactoryMutator<Service> = (_ resolver: Resolver, _ service: Service) -> Void

public class ResolverOptions<Service> {

    var scope: ResolverScope

    fileprivate var factory: ResolverFactoryArguments<Service>
    fileprivate var mutator: ResolverFactoryMutator<Service>?
    fileprivate weak var resolver: Resolver?

    public init(resolver: Resolver, factory: @escaping ResolverFactoryArguments<Service>) {
        self.factory = factory
        self.resolver = resolver
        self.scope = Resolver.defaultScope
    }

    @discardableResult
    public final func implements<Protocol>(_ type: Protocol.Type, name: String? = nil) -> ResolverOptions<Service> {
        resolver?.register(type.self, name: name) { r in r.resolve(Service.self) as? Protocol }
        return self
    }

    @discardableResult
    public final func resolveProperties(_ block: @escaping ResolverFactoryMutator<Service>) -> ResolverOptions<Service> {
        mutator = block
        return self
    }

    @discardableResult
    public final func scope(_ scope: ResolverScope) -> ResolverOptions<Service> {
        self.scope = scope
        return self
    }

}

public final class ResolverRegistration<Service>: ResolverOptions<Service> {

    public var key: Int
    public var namedRegistrations: [String : Any]?

    public init(resolver: Resolver, key: Int, factory: @escaping ResolverFactoryArguments<Service>) {
        self.key = key
        super.init(resolver: resolver, factory: factory)
    }

    public final func addRegistration(_ name: String, registration: Any) {
        if namedRegistrations == nil {
            namedRegistrations = [name:registration]
        } else {
            namedRegistrations?[name] = registration
        }
    }

    public final func resolve(resolver: Resolver) -> Service? {
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

    public final func resolve<Service>(resolver: Resolver, registration: ResolverRegistration<Service>) -> Service? {
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

    public final func reset() {
        pthread_mutex_lock(&mutex)
        cachedServices.removeAll()
        pthread_mutex_unlock(&mutex)
    }

    private var cachedServices = [Int : Any](minimumCapacity: 32)
    private var mutex = pthread_mutex_t()
}

public final class ResolverScopeGraph: ResolverScope {

    public final func resolve<Service>(resolver: Resolver, registration: ResolverRegistration<Service>) -> Service? {
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

    private var graph = [Int : Any?](minimumCapacity: 32)
    private var resolutionDepth: Int = 0
    private var mutex = pthread_mutex_t()
}

public final class ResolverScopeShare: ResolverScope {

    public final func resolve<Service>(resolver: Resolver, registration: ResolverRegistration<Service>) -> Service? {
        pthread_mutex_lock(&mutex)
        if let service = cachedServices[registration.key]?.service as? Service {
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

    private var cachedServices = [Int : BoxWeak](minimumCapacity: 32)
    private var mutex = pthread_mutex_t()
}

public final class ResolverScopeUnique: ResolverScope {

    public final func resolve<Service>(resolver: Resolver, registration: ResolverRegistration<Service>) -> Service? {
        return registration.resolve(resolver: resolver)
    }

}
