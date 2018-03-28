# Resolver: The Resolution Cycle


## The Code

Let's assume the following registrations and code.

```
extension Resolver: ResolverRegistering {

    public static func registerAllServices() {

        // Register instance with injected parameters
        main.register { XYZViewModel(fetcher: resolve(), updater: resolve(), service: resolve()) }

        // Register protocols XYZFetching and XYZUpdating
        main.register { XYZCombinedService() as XYZFetching }
        main.register { XYZCombinedService() as XYZUpdating }

        // Register XYZService and return instance in factory closure
        main.register { XYZService(session: resolve()) }

        // Register XYZSessionService and return instance in factory closure
        main.register { XYZSessionService() }

    }
}

class MyViewController: UIViewController {
    var xyz: XYZViewModel = Resolver.resolve()!
}
```

Note in particular the additonal parameters needed to create a `XYZViewModel` and a `XYZService`.

## The Process

When `Resolver.resolve()` is executed on MyViewController, the following occurs:

* Resolver infers the type of object being requested. (e.g. XYZViewModel)
* Resolver searches the registry for a registration of that type to in order to find the correct object factory.
* Resolver tells the factory to resolve.
* Resolving, the XYZViewModel factory wants to initialize an XYZViewModel, but to do so it first needs a fetcher, an updater, and a service object as parameters.
* Resolving, the XYZFetcher factory creates and returns a fetcher.
* Resolving, the XYZUpdater factory creates and returns an updater.
* Resolving, the XYZService factory wants to return an XYZService, but first the factory needs an XYZSessionService.
* Resolving, the XYZSessionService factory creates and returns a session.
* The XYZService gets its XYZSessionService, initializes, and returns.
* The XYZViewModel gets a XYZFetching instance, a XYZUpdating instance, and a XYZService instance and initializes and returns.

And MyViewController gets its XYZViewModel.

It doesn't know the internals of XYZViewModel, nor does it know about XYZFetcher's, XYZUpdater's, XYZService's, or XYZSessionService's.

Nor does it need to. It simply asks Resolver for an instance of type T, and Resolver complies.

This chain of events is known as a *Resolution Cycle*.
