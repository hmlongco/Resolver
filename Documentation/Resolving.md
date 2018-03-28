#  Resolver: Resolving

## Resolve using Resolver

Once registered, any object can reach out to Resolver directly to provide (resolve) an object of that type.

```
class MyViewController: UIViewController {
    var xyz: XYZViewModel = Resolver.resolve()!
}
```

Used in this fashion, Resolver would technically be acting as a *Service Locator*.

There are pros and cons to the Service Locator approach, the primary two being writing less code vs having your view controllers and other objects "know" about Resolver.

## Resolve using the Resolving protocol

Any object can implement and use the Resolving protocol, as shown in the folllowing two examples:

```
class MyViewController: UIViewController, Resolving {
    lazy var viewModel: XYZViewModel = resolver.resolve()!
}

class ABCExample: Resolving {
    lazy var service: ABCService = resolver.resolve()
}
```

Implementing the Resolving protocol injects the default Resolver into that class as a variable.

Calling resolve on the injected instance allows it to request a XYZViewModel from Resolver.

All resolution methods (e.g. `resolve()`, `optional()`) are available from the injected variable.


## Resolve using Interface Injection

If you're a bit more of a Dependency Injection purist, you can wrap Resolver as follows.

Add the following to your section's `xxxxx+Injection.swift` file:

```
extension MyViewController: Resolving {
    func makeViewModel() -> XYZViewModel { return resolver.resolve()! }
}
```

And now the code contained in  `MyViewController` becomes:

```
class MyViewController: UIViewController {
    lazy var viewModel = makeViewModel()
}
```

All the view controller knows is that a function was provided that gives it the view model that it wants.

Note that we're using an injected function to set our variable. It's possbile to do:

```
extension MyViewController: Resolving {
    var myViewModel: XYZViewModel { return resolver.resolve()! }
}
```

But that would resolve a new instance of XYZViewModel each and every time myViewModel is referenced in the code, and that's probably not what you want.

## Lazy

Note in the last several examples the parameter being resolved was lazy.

This delays initialization of the object until its needed, but it also avoids a Swift complier error. Consider the following:

```
class MyViewController: UIViewController, Resolving {
    var viewModel: XYZViewModel = resolver.resolve()! // Error
}
```

This will generate a Swift compiler error: *Cannot use instance member 'resolver' within property initializer; property initializers run before 'self' is available.*

Adding `lazy` fixes the problem, and also gives us the fexibility to do things like the following:

```
class ViewController: UIViewController, Resolving {
    var editMode: Bool = true // set by calling segue
    lazy var viewModel: XYZViewModelProtocol = resolver.resolve(name: editMode ? "edit" : "add")!
}
```

Here, the `lazy var` ensures that the viewModel resolution doesn't occur until after the viewController and it's properties are instantiated and after `prepareForSegue` has had a chance to correctly set `editMode`.

Named Intances are valuable tools to have in your toolkit [Learn more..](Names.md)

## Optionals

Resolver can also automatically resolve optionals... with one minor change.

```
var abc: ABCService? = resolver.optional()
var abc: ABCService! = resolver.optional()
```

Due to the way Swift type inference works, we need to give Resolver a clue that the type we're attempting to resolve is an optional, hence we use `resolver.optional()` and not `resolver.resolve()`.

Note the second line of code. You should also remember that Explicitly Unwrapped Optionals are still optionals at heart, and as such also need the hint.

**If a resolution is failing and you know you've registered the class, check to make sure your variable or parameter isn't an Optional or an Explicitly Unwrapped Optional!**

[Read more about Optionals.](Optionals.md)

## The Resolution Cycle

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
        main.register { XYZService() }

        // Register XYZSessionService and return instance in factory closure
        main.register { XYZSessionService() }

    }
}

class MyViewController: UIViewController {
    var xyz: XYZViewModel = Resolver.resolve()!
}
```

When `resolver.resolve()` is executed on MyViewController, the following occurs:

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

And MyViewController gets its XYZViewModel.

It doesn't know the internals of XYZViewModel, nor does it know about XYZFetcher's, XYZUpdater's, XYZService's, or XYZSessionService's.

Nor does it need to. It simply asks Resolver for an instance of type T, and Resolver complies.

This chain of events is known as a *Resolution Cycle*.

## ResolverStoryboard

You can also have Resolver *automatically* resolve view controllers instantiated from Storyboards. (Well, automatically from the view controller's standpoint, anyway.)

See: *ResolverStoryboard*

