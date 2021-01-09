#  Resolver: Threads

## Thread Safety

Resolver is designed to be thread safe during service registration and resolution.

Successful service resolution assumes, however, that all service registrations will occur **prior** to the first resolution request. If you kick off thread A to do registrations and then also kick off a thread B that needs to resolve some of those services... well, let's just say that bad things will occur.

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
