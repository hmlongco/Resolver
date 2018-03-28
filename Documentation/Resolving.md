#  Resolver: Resolving

## Resolve using Resolver

Once registered, any object can reach out to Resolver to provide (resolve) an instance of the requested type.

```
class MyViewController: UIViewController {
    var xyz: XYZViewModel = Resolver.resolve()
}
```

Used in this fashion, Resolver is acting as a *Service Locator*.

There are pros and cons to the Service Locator approach, the primary two being writing less code vs having your view controllers and other objects "know" about about your Service Locator (i.e. Resolver.)

Note that Resolver's static resolution methods are searching Resolver's **root** container, which is usually the **main** container. [See Containers.](Containers.md)

## Resolve using the Resolving protocol

Any object can implement the Resolving protocol, as shown in the folllowing two examples:

```
class MyViewController: UIViewController, Resolving {
    lazy var viewModel: XYZViewModel = resolver.resolve()
}

class ABCExample: Resolving {
    lazy var service: ABCService = resolver.resolve()
}
```

Implementing the Resolving protocol injects the default Resolver into that class as a variable. In this case, calling resolve on that instance allows MyViewController to request a XYZViewModel from Resolver.

All resolution methods available in Resolver (e.g. `resolve()`, `optional()`) are available from the injected variable.


## Resolve using Interface Injection

If you're a bit more of a Dependency Injection purist, you can wrap Resolver as follows.

Add the following to your section's `xxxxx+Injection.swift` file:

```
extension MyViewController: Resolving {
    func makeViewModel() -> XYZViewModel { return resolver.resolve() }
}
```

And now the code contained in  `MyViewController` becomes:

```
class MyViewController: UIViewController {
    lazy var viewModel = makeViewModel()
}
```

All the view controller knows is that a function was provided that gives it the view model that it wants.

Note that we're using an injected function to set our variable. It's *possbile* to do:

```
extension MyViewController: Resolving {
    var myViewModel: XYZViewModel { return resolver.resolve() }
}
```

But that would resolve a new instance of XYZViewModel each and every time myViewModel is referenced in the code, and that's probably not what you want. (Unless XYZViewModel is completely stateless.)

## Lazy

Note in the last few examples the parameter being resolved was designated as `lazy`.

This delays initialization of the object until its needed, but it also avoids a Swift compiler error. Consider the following:

```
class MyViewController: UIViewController, Resolving {
    var viewModel: XYZViewModel = resolver.resolve() // Error
}
```

This will generate a Swift compiler error: *Cannot use instance member 'resolver' within property initializer; property initializers run before 'self' is available.*

Or to put it another way, Swift can't use variables or call functions before all variables are known to be initialized. Adding `lazy` fixes the problem, and also gives us the fexibility to do things like the following:

```
class ViewController: UIViewController, Resolving {
    var editMode: Bool = true // set by calling segue
    lazy var viewModel: XYZViewModelProtocol = resolver.resolve(name: editMode ? "edit" : "add")
}
```

Here, the `lazy var` ensures that the viewModel resolution doesn't occur until after the viewController and its properties are instantiated and after `prepareForSegue` has had a chance to correctly set `editMode`.

Named Instances are valuable tools to have around. [Learn more..](Names.md)

## Optionals

Resolver can also automatically resolve optionals... with one minor change.

```
var abc: ABCService? = resolver.optional()
var xyz: XYZService! = resolver.optional()
```

Due to the way Swift type inference works, we need to give Resolver a clue that the type we're attempting to resolve is an optional, hence we use `resolver.optional()` and not `resolver.resolve()`.

Note the second line of code. You should also remember that Explicitly Unwrapped Optionals are still optionals at heart, and as such also need the hint.

**If a resolution is failing and you know you've registered the class, check to make sure your variable or parameter isn't an Optional or an Explicitly Unwrapped Optional!**

[Read more about Optionals.](Optionals.md)


## ResolverStoryboard

You can also have Resolver *automatically* resolve view controllers instantiated from Storyboards. (Well, automatically from the view controller's standpoint, anyway.)

See: *ResolverStoryboard*

