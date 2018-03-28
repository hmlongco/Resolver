#  Resolver: Resolving

## Resolve using Resolver

Once registered, any object can reach out to Resolver directly to provide (resolve) an object of that type.

```
var xyz: XYZViewModel = Resolver.resolve()
```

Used in this fashion, Resolver would technically be a *Service Locator*.

## Resolve using the Resolving protocol

Any object can implement the Resolving protocol, and as such have a resolver automatically injected into that class.

```
class MyViewController: UIViewController, Resolving {
    lazy var viewModel: XYZViewModel = resolver.resolve()!
}
```

Adopting the Resolving protocol injects the default resolver instance into MyViewController. Calling resolve on that instance allows it to request a XYZViewModel from Resolver.

To use more Dependency Injection lingo, resolver was added to MyViewController using *Interface Injection*, and resolver.resolve() acts as the *Service Locator* for MyViewController.

Note that the viewModel parameter is lazy, so when it's first accessed a *Resolution Cycle* kicks off.

## The Resolution Cycle

Let's assume the following registrations.

```
extension Resolver: ResolverRegistering {

public static func registerAllServices() {

// Register instance with injected parameters
main.register { XYZViewModel(fetcher: resolve(), updater: resolve(), service: resolve()) }

// Register protocols XYZFetching and XYZUpdating
main.register { XYZCombinedService() as XYZFetching }
main.register { XYZCombinedService() as XYZUpdating }

// Register XYZService and return instance in factory closure
main.register { XYZService() }

// Register XYZSessionService and return instance in factory closure
main.register { XYZSessionService() }

}

}
```

When `lazy var viewModel: XYZViewModel = resolver.resolve()` is executed, the following occurs:

* Resolver infers the type of object being requested. (e.g. XYZViewModel)
* Resolver searches the registry for a registration of that type to in order to find the correct object factory.
* Resolver tells the factory to resolve.
* Resolving, the XYZViewModel factory wants to initialize an XYZViewModel, but to do so it first needs a fetecher, an updater, and service object as parameters.
* Resolving, the XYZFetcher factory creates and returns a fetcher.
* Resolving, the XYZUpdater factory creates and returns an updater.
* Resolving, the XYZService factory wants to return an XYZService, but first it needs an XYZSessionService.
* Resolving, the XYZSessionService factory creates and returns a session.
* The XYZService gets its XYZSessionService, initializes, and returns.
* The XYZViewModel gets a XYZFetching instance, a XYZUpdating instance, and a XYZService instance and initializes and returns.

And MyViewController gets its XYZViewModel. It doesn't know the internals of XYZViewModel, nor does it know about XYZFetcher's, XYZUpdater's, XYZService's, or XYZSessionService's.

Nor does it need to. It simply asks Resolver for an instance of type T, and Resolver complies.

## Hiding Resolver

If you're a bit more of a Dependency Injection purist, you can wrap Resolver as follows.

Add the following to your section's `XYZ+Injection.swift` file:

```
extension MyViewController: Resolving {
    func makeViewModel() -> XYZViewModel { return resolver.resolve()! }
}
```

And now the code `MyViewController` becomes:

```
class MyViewController: UIViewController {
    lazy var viewModel = makeViewModel()
}
```

All the view controller knows is that a function was provided that gives it the view model that it wants.

This, again, is known as *Interface Injection".

## ResolverStoryboard

You can also have Resolver *automatically* resolve view controllers instantiated from Storyboards. (Well, automatically from the view controller's standpoint, anyway.)

See: *ResolverStoryboard*


