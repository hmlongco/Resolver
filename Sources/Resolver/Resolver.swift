//
// Resolver.swift
//
// GitHub Repo and Documentation: https://github.com/hmlongco/Resolver
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

#if os(iOS)
import UIKit
import SwiftUI
#elseif os(macOS) || os(tvOS) || os(watchOS)
import Foundation
import SwiftUI
#else
import Foundation
#endif

// swiftlint:disable file_length

public protocol ResolverRegistering {
    static func registerAllServices()
}

/// The Resolving protocol is used to make the Resolver registries available to a given class.
public protocol Resolving {
    var resolver: Resolver { get }
}

extension Resolving {
    public var resolver: Resolver {
        return Resolver.root
    }
}

/// Resolver is a Dependency Injection registry that registers Services for later resolution and
/// injection into newly constructed instances.
public final class Resolver {

    // MARK: - Defaults

    /// Default registry used by the static Registration functions.
    public static var main: Resolver = Resolver()
    /// Default registry used by the static Resolution functions and by the Resolving protocol.
    public static var root: Resolver = main
    /// Default scope applied when registering new objects.
    public static var defaultScope: ResolverScope = Resolver.graph

    // MARK: - Lifecycle

    public init(parent: Resolver? = nil) {
        self.parent = parent
    }

    /// Called by the Resolution functions to perform one-time initialization of the Resolver registries.
    public final func registerServices() {
        Resolver.registerServices?()
    }

    /// Called by the Resolution functions to perform one-time initialization of the Resolver registries.
    public static var registerServices: (() -> Void)? = registerServicesBlock

    private static var registerServicesBlock: (() -> Void) = { () in
        pthread_mutex_lock(&Resolver.registrationMutex)
        defer { pthread_mutex_unlock(&Resolver.registrationMutex) }
        if Resolver.registerServices != nil, let registering = (Resolver.root as Any) as? ResolverRegistering {
            type(of: registering).registerAllServices()
        }
        Resolver.registerServices = nil
    }

    /// Called to effectively reset Resolver to its initial state, including recalling registerAllServices if it was provided
    public static func reset() {
        pthread_mutex_lock(&Resolver.registrationMutex)
        defer { pthread_mutex_unlock(&Resolver.registrationMutex) }
        main = Resolver()
        root = main
        registerServices = registerServicesBlock
    }

    // MARK: - Service Registration

    /// Static shortcut function used to register a specifc Service type and its instantiating factory method.
    ///
    /// - parameter type: Type of Service being registered. Optional, may be inferred by factory result type.
    /// - parameter name: Named variant of Service being registered.
    /// - parameter factory: Closure that constructs and returns instances of the Service.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public static func register<Service>(_ type: Service.Type = Service.self, name: String? = nil,
                                         factory: @escaping ResolverFactory<Service>) -> ResolverOptions<Service> {
        return main.register(type, name: name, factory: factory)
    }

    /// Static shortcut function used to register a specifc Service type and its instantiating factory method.
    ///
    /// - parameter type: Type of Service being registered. Optional, may be inferred by factory result type.
    /// - parameter name: Named variant of Service being registered.
    /// - parameter factory: Closure that constructs and returns instances of the Service.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public static func register<Service>(_ type: Service.Type = Service.self, name: String? = nil,
                                         factory: @escaping ResolverFactoryResolver<Service>) -> ResolverOptions<Service> {
        return main.register(type, name: name, factory: factory)
    }

    /// Static shortcut function used to register a specifc Service type and its instantiating factory method with multiple argument support.
    ///
    /// - parameter type: Type of Service being registered. Optional, may be inferred by factory result type.
    /// - parameter name: Named variant of Service being registered.
    /// - parameter factory: Closure that accepts arguments and constructs and returns instances of the Service.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public static func register<Service>(_ type: Service.Type = Service.self, name: String? = nil,
                                         factory: @escaping ResolverFactoryArgumentsN<Service>) -> ResolverOptions<Service> {
        return main.register(type, name: name, factory: factory)
    }

    /// Registers a specifc Service type and its instantiating factory method.
    ///
    /// - parameter type: Type of Service being registered. Optional, may be inferred by factory result type.
    /// - parameter name: Named variant of Service being registered.
    /// - parameter factory: Closure that constructs and returns instances of the Service.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public final func register<Service>(_ type: Service.Type = Service.self, name: String? = nil,
                                        factory: @escaping ResolverFactory<Service>) -> ResolverOptions<Service> {
        let key = ObjectIdentifier(Service.self).hashValue
        let registration = ResolverRegistrationOnly(resolver: self, key: key, name: name, factory: factory)
        add(registration: registration, with: key, name: name)
        return registration
    }

    /// Registers a specifc Service type and its instantiating factory method.
    ///
    /// - parameter type: Type of Service being registered. Optional, may be inferred by factory result type.
    /// - parameter name: Named variant of Service being registered.
    /// - parameter factory: Closure that constructs and returns instances of the Service.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public final func register<Service>(_ type: Service.Type = Service.self, name: String? = nil,
                                        factory: @escaping ResolverFactoryResolver<Service>) -> ResolverOptions<Service> {
        let key = ObjectIdentifier(Service.self).hashValue
        let registration = ResolverRegistrationResolver(resolver: self, key: key, name: name, factory: factory)
        add(registration: registration, with: key, name: name)
        return registration
    }

    /// Registers a specifc Service type and its instantiating factory method with multiple argument support.
    ///
    /// - parameter type: Type of Service being registered. Optional, may be inferred by factory result type.
    /// - parameter name: Named variant of Service being registered.
    /// - parameter factory: Closure that accepts arguments and constructs and returns instances of the Service.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public final func register<Service>(_ type: Service.Type = Service.self, name: String? = nil,
                                        factory: @escaping ResolverFactoryArgumentsN<Service>) -> ResolverOptions<Service> {
        let key = ObjectIdentifier(Service.self).hashValue
        let registration = ResolverRegistrationArgumentsN(resolver: self, key: key, name: name, factory: factory)
        add(registration: registration, with: key, name: name)
        return registration
    }

    // MARK: - Service Resolution

    /// Static function calls the root registry to resolve a given Service type.
    ///
    /// - parameter type: Type of Service being resolved. Optional, may be inferred by assignment result type.
    /// - parameter name: Named variant of Service being resolved.
    /// - parameter args: Optional arguments that may be passed to registration factory.
    ///
    /// - returns: Instance of specified Service.
    public static func resolve<Service>(_ type: Service.Type = Service.self, name: String? = nil, args: Any? = nil) -> Service {
        Resolver.registerServices?() // always check initial registrations first in case registerAllServices swaps root
        return root.resolve(type, name: name, args: args)
    }

    /// Resolves and returns an instance of the given Service type from the current registry or from its
    /// parent registries.
    ///
    /// - parameter type: Type of Service being resolved. Optional, may be inferred by assignment result type.
    /// - parameter name: Named variant of Service being resolved.
    /// - parameter args: Optional arguments that may be passed to registration factory.
    ///
    /// - returns: Instance of specified Service.
    ///
    public final func resolve<Service>(_ type: Service.Type = Service.self, name: String? = nil, args: Any? = nil) -> Service {
        if let registration = lookup(type, name: name ?? NONAME),
            let service = registration.scope.resolve(resolver: self, registration: registration, args: args) {
            return service
        }
        fatalError("RESOLVER: '\(Service.self):\(name ?? "")' not resolved. To disambiguate optionals use resolver.optional().")
    }

    /// Static function calls the root registry to resolve an optional Service type.
    ///
    /// - parameter type: Type of Service being resolved. Optional, may be inferred by assignment result type.
    /// - parameter name: Named variant of Service being resolved.
    /// - parameter args: Optional arguments that may be passed to registration factory.
    ///
    /// - returns: Instance of specified Service.
    ///
    public static func optional<Service>(_ type: Service.Type = Service.self, name: String? = nil, args: Any? = nil) -> Service? {
        Resolver.registerServices?() // always check initial registrations first in case registerAllServices swaps root
        return root.optional(type, name: name, args: args)
    }

    /// Resolves and returns an optional instance of the given Service type from the current registry or
    /// from its parent registries.
    ///
    /// - parameter type: Type of Service being resolved. Optional, may be inferred by assignment result type.
    /// - parameter name: Named variant of Service being resolved.
    /// - parameter args: Optional arguments that may be passed to registration factory.
    ///
    /// - returns: Instance of specified Service.
    ///
    public final func optional<Service>(_ type: Service.Type = Service.self, name: String? = nil, args: Any? = nil) -> Service? {
        if let registration = lookup(type, name: name ?? NONAME),
            let service = registration.scope.resolve(resolver: self, registration: registration, args: args) {
            return service
        }
        return nil
    }

    // MARK: - Internal

    /// Internal function searches the current and parent registries for a ResolverRegistration<Service> that matches
    /// the supplied type and name.
    private final func lookup<Service>(_ type: Service.Type, name: String) -> ResolverRegistration<Service>? {
        Resolver.registerServices?()
        if let container = registrations[ObjectIdentifier(Service.self).hashValue], let registration = container[name] {
            return registration as? ResolverRegistration<Service>
        }
        if let parent = parent, let registration = parent.lookup(type, name: name) {
            return registration
        }
        return nil
    }

    /// Internal function adds a new registration to the proper container.
    private final func add<Service>(registration: ResolverRegistration<Service>, with key: Int, name: String?) {
        if var container = registrations[key] {
            container[name ?? NONAME] = registration
            registrations[key] = container
        } else {
            registrations[key] = [name ?? NONAME : registration]
        }
    }

    private let NONAME = "*"
    private let parent: Resolver?
    private var registrations = [Int : [String : Any]]()
    private static var registrationMutex: pthread_mutex_t = {
        var mutex = pthread_mutex_t()
        pthread_mutex_init(&mutex, nil)
        return mutex
    }()
}

// Resolver Multiple Argument Support

extension Resolver {

    public struct Args {

        private var args: [String:Any?]

        public init(_ args: Any?) {
            if let args = args as? [String:Any?] {
                self.args = args
            } else {
                self.args = ["" : args]
             }
        }

        #if swift(>=5.2)
        public func callAsFunction<T>() -> T {
            assert(args.count == 1, "argument order indeterminate, use keyed arguments")
            return (args.first?.value as? T)!
        }

        public func callAsFunction<T>(_ key: String) -> T {
            return (args[key] as? T)!
        }
        #endif

        public func optional<T>() -> T? {
            return args.first?.value as? T
        }

        public func optional<T>(_ key: String) -> T? {
            return args[key] as? T
        }

        public func get<T>() -> T {
            assert(args.count == 1, "argument order indeterminate, use keyed arguments")
            return (args.first?.value as? T)!
        }

        public func get<T>(_ key: String) -> T {
            return (args[key] as? T)!
        }
        
    }

}

// Registration Internals

public typealias ResolverFactory<Service> = () -> Service?
public typealias ResolverFactoryResolver<Service> = (_ resolver: Resolver) -> Service?
public typealias ResolverFactoryArgumentsN<Service> = (_ resolver: Resolver, _ args: Resolver.Args) -> Service?
public typealias ResolverFactoryMutator<Service> = (_ resolver: Resolver, _ service: Service) -> Void
public typealias ResolverFactoryMutatorArgumentsN<Service> = (_ resolver: Resolver, _ service: Service, _ args: Resolver.Args) -> Void

/// A ResolverOptions instance is returned by a registration function in order to allow additonal configuratiom. (e.g. scopes, etc.)
public class ResolverOptions<Service> {

    // MARK: - Parameters

    public var scope: ResolverScope

    fileprivate var mutator: ResolverFactoryMutator<Service>?
    fileprivate var mutatorWithArgumentsN: ResolverFactoryMutatorArgumentsN<Service>?
    fileprivate weak var resolver: Resolver?

    // MARK: - Lifecycle

    public init(resolver: Resolver) {
        self.resolver = resolver
        self.scope = Resolver.defaultScope
    }

    // MARK: - Fuctionality

    /// Indicates that the registered Service also implements a specific protocol that may be resolved on
    /// its own.
    ///
    /// - parameter type: Type of protocol being registered.
    /// - parameter name: Named variant of protocol being registered.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public final func implements<Protocol>(_ type: Protocol.Type, name: String? = nil) -> ResolverOptions<Service> {
        resolver?.register(type.self, name: name) { r, _ in r.resolve(Service.self) as? Protocol }
        return self
    }

    /// Allows easy assignment of injected properties into resolved Service.
    ///
    /// - parameter block: Resolution block.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public final func resolveProperties(_ block: @escaping ResolverFactoryMutator<Service>) -> ResolverOptions<Service> {
        mutator = block
        return self
    }

    /// Allows easy assignment of injected properties into resolved Service.
    ///
    /// - parameter block: Resolution block that also receives resolution arguments.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public final func resolveProperties(_ block: @escaping ResolverFactoryMutatorArgumentsN<Service>) -> ResolverOptions<Service> {
        mutatorWithArgumentsN = block
        return self
    }

    /// Defines scope in which requested Service may be cached.
    ///
    /// - parameter block: Resolution block.
    ///
    /// - returns: ResolverOptions instance that allows further customization of registered Service.
    ///
    @discardableResult
    public final func scope(_ scope: ResolverScope) -> ResolverOptions<Service> {
        self.scope = scope
        return self
    }

    /// Internal function to apply mutations with and w/o arguments
    fileprivate func mutate(_ service: Service, resolver: Resolver, args: Any?) {
        self.mutator?(resolver, service)
        if let mutatorWithArgumentsN = mutatorWithArgumentsN {
            mutatorWithArgumentsN(resolver, service, Resolver.Args(args))
        }
    }
}

/// ResolverRegistration base class stores the registration keys.
public class ResolverRegistration<Service>: ResolverOptions<Service> {

    public var key: Int
    public var cacheKey: String

    public init(resolver: Resolver, key: Int, name: String?) {
        self.key = key
        if let namedService = name {
            self.cacheKey = String(key) + ":" + namedService
        } else {
            self.cacheKey = String(key)
        }
        super.init(resolver: resolver)
    }

    public func resolve(resolver: Resolver, args: Any?) -> Service? {
        fatalError("abstract function")
    }

}

/// ResolverRegistration stores a service definition and its factory closure.
public final class ResolverRegistrationOnly<Service>: ResolverRegistration<Service> {

    public var factory: ResolverFactory<Service>

    public init(resolver: Resolver, key: Int, name: String?, factory: @escaping ResolverFactory<Service>) {
        self.factory = factory
        super.init(resolver: resolver, key: key, name: name)
    }

    public final override func resolve(resolver: Resolver, args: Any?) -> Service? {
        guard let service = factory() else {
            return nil
        }
        mutate(service, resolver: resolver, args: args)
        return service
    }
}

/// ResolverRegistrationResolver stores a service definition and its factory closure.
public final class ResolverRegistrationResolver<Service>: ResolverRegistration<Service> {

    public var factory: ResolverFactoryResolver<Service>

    public init(resolver: Resolver, key: Int, name: String?, factory: @escaping ResolverFactoryResolver<Service>) {
        self.factory = factory
        super.init(resolver: resolver, key: key, name: name)
    }

    public final override func resolve(resolver: Resolver, args: Any?) -> Service? {
        guard let service = factory(resolver) else {
            return nil
        }
        mutate(service, resolver: resolver, args: args)
        return service
    }
}

/// ResolverRegistrationArguments stores a service definition and its factory closure.
public final class ResolverRegistrationArgumentsN<Service>: ResolverRegistration<Service> {

    public var factory: ResolverFactoryArgumentsN<Service>

    public init(resolver: Resolver, key: Int, name: String?, factory: @escaping ResolverFactoryArgumentsN<Service>) {
        self.factory = factory
        super.init(resolver: resolver, key: key, name: name)
    }

    public final override func resolve(resolver: Resolver, args: Any?) -> Service? {
        guard let service = factory(resolver, Resolver.Args(args)) else {
            return nil
        }
        mutate(service, resolver: resolver, args: args)
        return service
    }
}

// Scopes

extension Resolver {

    // MARK: - Scopes

    /// All application scoped services exist for lifetime of the app. (e.g Singletons)
    public static let application = ResolverScopeApplication()
    /// Cached services exist for lifetime of the app or until their cache is reset.
    public static let cached = ResolverScopeCache()
    /// Graph services are initialized once and only once during a given resolution cycle. This is the default scope.
    public static let graph = ResolverScopeGraph()
    /// Shared services persist while strong references to them exist. They're then deallocated until the next resolve.
    public static let shared = ResolverScopeShare()
    /// Unique services are created and initialized each and every time they're resolved.
    public static let unique = ResolverScopeUnique()

}

/// Resolver scopes exist to control when resolution occurs and how resolved instances are cached. (If at all.)
public protocol ResolverScope: class {
    func resolve<Service>(resolver: Resolver, registration: ResolverRegistration<Service>, args: Any?) -> Service?
}

/// All application scoped services exist for lifetime of the app. (e.g Singletons)
public class ResolverScopeApplication: ResolverScope {

    public init() {
        pthread_mutex_init(&mutex, nil)
    }

    public final func resolve<Service>(resolver: Resolver, registration: ResolverRegistration<Service>, args: Any?) -> Service? {
        pthread_mutex_lock(&mutex)
        let existingService = cachedServices[registration.cacheKey] as? Service
        pthread_mutex_unlock(&mutex)

        if let service = existingService {
            return service
        }

        let service = registration.resolve(resolver: resolver, args: args)

        if let service = service {
            pthread_mutex_lock(&mutex)
            cachedServices[registration.cacheKey] = service
            pthread_mutex_unlock(&mutex)
        }

        return service
    }

    fileprivate var cachedServices = [String : Any](minimumCapacity: 32)
    fileprivate var mutex = pthread_mutex_t()
}

/// Cached services exist for lifetime of the app or until their cache is reset.
public final class ResolverScopeCache: ResolverScopeApplication {

    override public init() {
        super.init()
    }

    public final func reset() {
        pthread_mutex_lock(&mutex)
        cachedServices.removeAll()
        pthread_mutex_unlock(&mutex)
    }
}

/// Graph services are initialized once and only once during a given resolution cycle. This is the default scope.
public final class ResolverScopeGraph: ResolverScope {

    public init() {
        pthread_mutex_init(&mutex, nil)
    }

    public final func resolve<Service>(resolver: Resolver, registration: ResolverRegistration<Service>, args: Any?) -> Service? {

        pthread_mutex_lock(&mutex)

        let existingService = graph[registration.cacheKey] as? Service

        if let service = existingService {
            pthread_mutex_unlock(&mutex)
            return service
        }

        resolutionDepth = resolutionDepth + 1

        pthread_mutex_unlock(&mutex)

        let service = registration.resolve(resolver: resolver, args: args)

        pthread_mutex_lock(&mutex)

        resolutionDepth = resolutionDepth - 1

        if resolutionDepth == 0 {
            graph.removeAll()
        } else if let service = service, type(of: service as Any) is AnyClass {
            graph[registration.cacheKey] = service
        }

        pthread_mutex_unlock(&mutex)

        return service
    }

    private var graph = [String : Any?](minimumCapacity: 32)
    private var resolutionDepth: Int = 0
    private var mutex = pthread_mutex_t()
}

/// Shared services persist while strong references to them exist. They're then deallocated until the next resolve.
public final class ResolverScopeShare: ResolverScope {

    public init() {
        pthread_mutex_init(&mutex, nil)
    }

    public final func resolve<Service>(resolver: Resolver, registration: ResolverRegistration<Service>, args: Any?) -> Service? {
        pthread_mutex_lock(&mutex)
        let existingService = cachedServices[registration.cacheKey]?.service as? Service
        pthread_mutex_unlock(&mutex)

        if let service = existingService {
            return service
        }

        let service = registration.resolve(resolver: resolver, args: args)

        if let service = service, type(of: service as Any) is AnyClass {
            pthread_mutex_lock(&mutex)
            cachedServices[registration.cacheKey] = BoxWeak(service: service as AnyObject)
            pthread_mutex_unlock(&mutex)
        }

        return service
    }

    public final func reset() {
        pthread_mutex_lock(&mutex)
        cachedServices.removeAll()
        pthread_mutex_unlock(&mutex)
    }

    private struct BoxWeak {
        weak var service: AnyObject?
    }

    private var cachedServices = [String : BoxWeak](minimumCapacity: 32)
    private var mutex = pthread_mutex_t()
}

/// Unique services are created and initialized each and every time they're resolved.
public final class ResolverScopeUnique: ResolverScope {

    public init() {}
    public final func resolve<Service>(resolver: Resolver, registration: ResolverRegistration<Service>, args: Any?) -> Service? {
        return registration.resolve(resolver: resolver, args: args)
    }

}

#if os(iOS)
/// Storyboard Automatic Resolution Protocol
public protocol StoryboardResolving: Resolving {
    func resolveViewController()
}

/// Storyboard Automatic Resolution Trigger
public extension UIViewController {
    // swiftlint:disable unused_setter_value
    @objc dynamic var resolving: Bool {
        get {
            return true
        }
        set {
            if let vc = self as? StoryboardResolving {
                vc.resolveViewController()
            }
        }
    }
    // swiftlint:enable unused_setter_value
}
#endif

// Swift Property Wrappers

#if swift(>=5.1)
/// Immediate injection property wrapper.
///
/// Wrapped dependent service is resolved immediately using Resolver.root upon struct initialization.
///
@propertyWrapper
public struct Injected<Service> {
    private var service: Service
    public init() {
        self.service = Resolver.resolve(Service.self)
    }
    public init(name: String? = nil, container: Resolver? = nil) {
        self.service = container?.resolve(Service.self, name: name) ?? Resolver.resolve(Service.self, name: name)
    }
    public var wrappedValue: Service {
        get { return service }
        mutating set { service = newValue }
    }
    public var projectedValue: Injected<Service> {
        get { return self }
        mutating set { self = newValue }
    }
}

/// Lazy injection property wrapper. Note that embedded container and name properties will be used if set prior to service instantiation.
///
/// Wrapped dependent service is not resolved until service is accessed.
///
@propertyWrapper
public struct LazyInjected<Service> {
    private var initialize: Bool = true
    private var service: Service!
    public var container: Resolver?
    public var name: String?
    public var args: Any?
    public init() {}
    public init(name: String? = nil, container: Resolver? = nil) {
        self.name = name
        self.container = container
    }
    public var isEmpty: Bool {
        return service == nil
    }
    public var wrappedValue: Service {
        mutating get {
            if initialize {
                self.initialize = false
                self.service = container?.resolve(Service.self, name: name, args: args) ?? Resolver.resolve(Service.self, name: name, args: args)
            }
            return service
        }
        mutating set { service = newValue  }
    }
    public var projectedValue: LazyInjected<Service> {
        get { return self }
        mutating set { self = newValue }
    }
    public mutating func release() {
        self.service = nil
    }
}

/// Weak lazy injection property wrapper. Note that embedded container and name properties will be used if set prior to service instantiation.
///
/// Wrapped dependent service is not resolved until service is accessed.
///
@propertyWrapper
public struct WeakLazyInjected<Service:AnyObject> {
    private var initialize: Bool = true
    private weak var service: Service?
    public var container: Resolver?
    public var name: String?
    public var args: Any?
    public init() {}
    public init(name: String? = nil, container: Resolver? = nil) {
        self.name = name
        self.container = container
    }
    public var isEmpty: Bool {
        return service == nil
    }
    public var wrappedValue: Service? {
        mutating get {
            if initialize {
                self.initialize = false
                let service = container?.resolve(Service.self, name: name, args: args) ?? Resolver.resolve(Service.self, name: name, args: args)
                self.service = service
                return service
            }
            return service
        }
        mutating set { service = newValue  }
    }
    public var projectedValue: WeakLazyInjected<Service> {
        get { return self }
        mutating set { self = newValue }
    }
}

@propertyWrapper
public struct OptionalInjected<Service> {
    private var service: Service?
    public init() {
        self.service = Resolver.optional(Service.self)
    }
    public init(name: String? = nil, container: Resolver? = nil) {
        self.service = container?.optional(Service.self, name: name) ?? Resolver.optional(Service.self, name: name)
    }
    public var wrappedValue: Service? {
        get { return service }
        mutating set { service = newValue }
    }
    public var projectedValue: OptionalInjected<Service> {
        get { return self }
        mutating set { self = newValue }
    }
}

/// Immediate injection property wrapper for SwiftUI ObservableObjects. This wrapper is meant for use in SwiftUI Views and exposes
/// bindable objects similar to that of SwiftUI @observedObject and @environmentObject.
///
/// Dependent service must be of type ObservableObject. Updating object state will trigger view update.
///
/// Wrapped dependent service is resolved immediately using Resolver.root upon struct initialization.
///
#if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
@available(OSX 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
@propertyWrapper
public struct InjectedObject<Service>: DynamicProperty where Service: ObservableObject {
    @ObservedObject private var service: Service
    public init() {
        self.service = Resolver.resolve(Service.self)
    }
    public init(name: String? = nil, container: Resolver? = nil) {
        self.service = container?.resolve(Service.self, name: name) ?? Resolver.resolve(Service.self, name: name)
    }
    public var wrappedValue: Service {
        get { return service }
        mutating set { service = newValue }
    }
    public var projectedValue: ObservedObject<Service>.Wrapper {
        return self.$service
    }
}
#endif
#endif
