#  Resolver: Threads

## Thread Safety

For performance reasons, Resolver is designed to be thread safe during object resolution.

By this I mean that the various scopes and caches should play nice with one another in a multi-threaded environment.

This assumes that all object registrations will occur **prior** to the first resolution request.

If you use `ResolverRegistering.registerAllServices` to register all of your dependencies, then you shouldn't have any issues.

```
import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {

    }
}
```
Resolver will attempt to protect the registration sequence during initial application launch.

If, on the other hand, you're kicking off multiple threads on app launch or if you're performing new registrations while your application is running then it's entirely possible you could see race conditions.

Resolver wasn't really designed for that. Sorry.
