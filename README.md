# Resolver ![icon](https://user-images.githubusercontent.com/709283/32858974-cce8282a-ca12-11e7-944b-c8046156290b.png)
Swift Ultralight Dependency Injection / Service Locator framework

```
extension Resolver: ResolverRegistering {

public static func registerAllServices() {

// Register XYZService and return instance in factory closure
main.register { XYZService() }

// Register instance with injected parameters
main.register { XYZViewModel(fetcher: resolve(), updater: resolve(), service: resolve()) }

// Register protocols XYZFetching and XYZUpdating
main.register { XYZCombinedService() as XYZFetching }
main.register { XYZCombinedService() as XYZUpdating }

// Note each registration factory above returns its own object, even though interfaces are in same object.
// To have XYZViewModel resolve interfaces to the same object in the same graph you could do...
main.register { resolve() as XYZCombinedService as XYZFetching }
main.register { resolve() as XYZCombinedService as XYZUpdating }
main.register { XYZCombinedService() }

// Or use this shorthand approach...
main.register { XYZCombinedService() }
.implements(XYZFetching.self)
.implements(XYZUpdating.self)

}

}
```

[API Documentation](./Documentation/API/index.html)
