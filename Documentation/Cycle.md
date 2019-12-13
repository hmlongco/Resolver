# Resolver: The Resolution Cycle

## The Code

Let's start with the following registration code.

```swift
extension Resolver: ResolverRegistering {

    public static func registerAllServices() {

        // Register instance with injected parameters
        main.register { XYZViewModel(fetcher: resolve(), updater: resolve(), service: resolve()) }

        // Register protocols XYZFetching and XYZUpdating
        main.register { resolve() as XYZCombinedService as XYZFetching }
        main.register { resolve() as XYZCombinedService as XYZUpdating }

        // Register the dependent service needed by the above protocols
        main.register { XYZCombinedService() }

        // Register XYZService
        main.register { XYZService(session: resolve()) }

        // Register the dependent service needed by XYZService
        main.register { XYZSessionService() }

    }
}
```

Note in particular the additional parameters needed to create a `XYZViewModel` and a `XYZService`.

## The Process

Let's kick things off by given a view controller its view model.

```swift
class MyViewController: UIViewController {
    let xyz: XYZViewModel = Resolver.resolve()
}
```

Assuming the default [graph](Scopes.md#graph) scope, the following now occurs:

1. Resolver infers the type of object being requested. (e.g. XYZViewModel)
2. Resolver searches the registry for a registration of that type to in order to find the correct object factory.
3. Resolver finds the XYZViewModel registration, and tells its factory to resolve.
4. Attempting to resolve XYZViewModel, its factory first needs a fetcher, an updater, and a service object as parameters.
5. Resolving, the XYZFetching registration is found, and its factory attempts to resolve an XYZCombinedService.
6. Resolving, the XYZCombinedService registration is found, and its factory creates and returns a combined service.
7. The XYZFetching factory now initializes and returns its service.
8. Resolving, the XYZUpdating registration is found, and its factory attempts to resolve an XYZCombinedService.
9. Resolver finds the previously resolved XYZCombinedService in its resolution graph, and returns it.
10. The XYZUpdating factory now initializes and returns its service.
11. Resolving, the XYZService registration is found, but its factory needs an XYZSessionService.
12. Resolving, the XYZSessionService registration is found, and its factory creates and returns a session.
13. The XYZService factory now initializes and returns its service.
14. The XYZViewModel factory now has a XYZFetching instance, a XYZUpdating instance, and a XYZService instance.
15. The XYZViewModel factory now initializes and returns.

And MyViewController gets its XYZViewModel.

MyViewController doesn't know the internals of XYZViewModel, nor does it know about XYZFetcher's, XYZUpdater's, XYZService's, or XYZSessionService's.

Nor does it need to. It simply asks Resolver for an instance of type T, and Resolver complies.

This chain of events is known as a *Resolution Cycle*.
