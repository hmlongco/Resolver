#  Resolver: Threads

## Thread Safety

Resolver uses a unique recursive locking strategy and is designed to be thread safe during service registration and resolution.

Successful service resolution assumes, however, that all service registrations will occur **prior** to the first resolution request. 

If you kick off thread A to do registrations and then also kick off a thread B that needs to resolve some of those services... well, let's just say that bad things will probably occur as you're setting up a race between registrations and resolutions. It's hard, after all, to resolve a request for `XYZService` if the factory for that service has yet to be registered.

Fortunately, Resolver has a solution for that.

## ResolverRegistering

If you use `ResolverRegistering.registerAllServices` to register all of your dependencies, then you shouldn't have any issues.

```swift
import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        registerMyNetworkServices()
        registerMyViewModels()
    }
    
    public static func registerMyNetworkServices() {
        register { ServiceA() }
        register { ServiceB() }
    }
    
    public static func registerMyViewModels() {
        register { ModelA() }
        register { ModelB() }
    }
}
```

Resolver will automatically call `registerAllServices` the very first time it's asked to resolve a particular service, ensuring that everything is properly registered before it goes looking for it.

For more, see the section on [Registration.](Registration.md)
