#  Resolver: Arguments

## Resolver 1.2 and Multiple Argument Support

Resolver 1.2 changed how arguments are passed to the registration factory order to provide better support for passing and handling both single and multiple arguments.  This is, unfortunately, a breaking change to Resolver, but as the end result is much cleaner code I think it's worth it. 

**This change only affects factories that expected a passed argument, and that expected that argument to be of type Any?.**

## Passing Arguments to a Registration Factory

Consider the following code:

```swift
class ViewController: UIViewController, Resolving {
    var editMode: Bool = true // set, perhaps, by calling segue
    lazy var viewModel: XYZViewModel = resolver.resolve(args: editMode)
}
```
This is passing a single boolean argument to Resolver through the `args` parameter, which in turn will provide it to the registration factory accessible from a custom type, `Resolver.Args`.

```swift
register { (_, args) in 
    XYZViewModel(editMode: args())
}
```
Here we're using the new `callAsFunction` feature from Swift 5.2 to immediately obtain our single passed argument from the `args` parameter.  The `editMode` parameter expected by the `XYZViewModel` initialization function is boolean, so Resolver automatically infers the type and returns the proper value.

If your project isn't yet building with Swift 5.2, then you'll need to use the fallback `get` function to access the passed value. 
```swift
register { (_, args) in 
XYZViewModel(editMode: args.get())
}
```
I think you'll agree the `callAsFunction` version is much nicer. 

Note that in both cases Resolver is attempting to infer the argument type based on the type of the expected value.  Prior to Resolver 1.2, you would have been required to cast the type manually from `Any?` to `Bool` and correctly handle the optional result.

```swift
register { (_, args) in 
    XYZViewModel(editMode: args as? Bool ?? true)
}
```

## Passing and Handling Multiple Arguments

Handling multiple arguments is done simply by passing a dictionary to Resolver.

```swift
class ViewController: UIViewController, Resolving {
    lazy var viewModel: XYZViewModel = resolver.resolve(args: ["mode": true, "name": "Editing")
}
```

When the  `args` value passed to Resolver is of type `[String:Any?]`, Resolver will again let you obtain the values through the `callAsFunction` syntax, this time using the dictionary key:
```swift
register { (_, args) in 
    XYZViewModel(editMode: args("mode"), name: args("name"))
}
```
Again, both types are automatically inferred.

## Optional Values

Resolver's default mode is to explicitly unwrap and provide the value using the `callAsFunction` syntax. If a parameter may be optional then you can use the `optional` function on `Resolver.Args` to obtain it. 

```swift
register { (_, args) in 
    XYZService(someOptionalValue: args.optional())
}
```
Like `get`,  the  `optional` function will also take a key name if you're passing a dictionary with multiple parameters.
```swift
register { (_, args) in 
    XYZViewModel(editMode: args("mode"), name: args.optional("name"))
}
```

## Arguments as Properties

An `editMode` property could also be set on a model as follows:

```swift
register { XYZViewModel(fetcher: resolve(), updater: resolve(), service: resolve()) }
    .resolveProperties { (resolver, model, args) in
        model.editMode = args()
    }
```
The `callAsFunction` syntax works here as well, for both single and multiple arguments. This too is a breaking change for Resolver 1.2 as the previous `args` argument  passed to `resolveProperties` was type `Any?`.

## Using Arguments to Manipulate Factory Behavior

It's possible to use passed arguments to change how Resolver will resolve a certain type:

```swift
register { (_, args) -> XYZViewModel in
    let editing: Bool = args()
    let updater: XYZUpdating = editing ? resolve(XYZUpdateEdit.self) : resolve(XYZUpdateAdd.self)
    return XYZViewModel(fetcher: resolve(), updater: updater, service: resolve())
}
register { XYZUpdateAdd() }
register { XYZUpdateEdit() }
```

Here we're giving XYZViewModel different object updaters, depending upon whether or not we're editing our data or adding it.

Note the use of `register { (_, arg) -> XYZViewModel in` on the first line.

In addition to using the closure factory arguments, we're also explicitly specifying the return type. Complex, multiple line factories like this one can cause Swift to lose track of the actual return type. Explicitly specifying the type clears up the confusion.

## Injected Property Wrappers

Note that arguments can't be specified or passed using the @Injected property wrapper. 

Why? Because property wrappers are at heart properties and they're immediately instantiated when their enclosing object is instantiated. This happens *prior* to that object's `init()` function being called and *prior* to `self` being available. As such, there's simply no way for a property wrapper to see or access the needed data. 

It can't, for example, do `@Injected(args: self.editMode) var viewModel: XYZViewModel` as `self` isn't available. Swift won't allow it.

That said, it's possible to be sneaky about it and pass arguments using `@LazyInjected`.
```
class NamedInjectedViewController: UIViewController {
    @LazyInjected var service: XYZNameService
    var editMode: Bool
    override func viewDidLoad() {
        super.viewDidLoad()
        $service.args = editMode
    }
}
```
You can also set `args` to a `[String:Any?]` dictionary if need be. Just make sure you set the `args` parameter on the property *prior* to accessing the service for the first time.

## Problems?

Be careful when passing and unpacking arguments. If you get a crash during resolution double-check the key name and type of your passed arguments against those used and expected by the resolution factory. 

If the inferred type doesn't match the type passed in `args` or in the dictionary, or if a key value is not found, then Resolver will fail when it attempts to explicitly unwrap the resulting value.

Which brings us to...

## The Case AGAINST Arguments
Resolver supports handling single and multiple arguments because it's needed from time to time, and, quite frankly,  because people have asked for it to do so.

Unfortunately, there are still issues with Resolver's implmentation: 

1. The biggest problem is that it erases the type information between the caller and the registration factory.
2. Since types are inferred and explicitly unwrapped, it's possible for the factory to fail to correctly resolve the passed arguments.
3. String-based dictionary keys can also be prone to failure if key names are mismatched between the dictionary and the factory.

Note that an earlier solution to this problem used generically named positional arguments( `arg0`, `arg1`, etc.). This approach had the type-inferrence problem *and* eliminated value semantics and as such was even more problematic.

If the above list has convinced you that blindly passing type-erased arguments to object factories might not be so wonderful after all, then good. 

Becaue there's a better way.

## Inject Services, Not Data

One of the things that many people miss is that dependency injection’s concern lies in constructing the service graph. 

To put that into English, it means the dependency-injection system creates and connects the *services* and the *components* that manage and process the application’s data. Data is information that's created and manipulated at runtime and passed from object to dependent object using an object’s methods and functions.

Data is never injected.

If an object requires data or values created or manipulated during runtime I'd do something like the following....
```
class DummyViewModel {
    func load(id: Int, editing: Bool) { }
}

class DummyViewController: UIViewController {

    var id: Int = 0
    var editing: Bool = false

    @Injected var viewModel: DummyViewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        someSetup()
        viewModel.load(id: id, editing: editing)
    }
}
```
Our `DummyViewModel` service is automatically injected when `DummyViewController` is instantiated, but it's load method is called with the needed parameters during `viewDidLoad`.

Note that type information is now preserved. Argument order is maintained. And explicit unwrapping of arguments is not required.

Plus I now have the added benefit of being able to control exactly when and where in the code I call my configuration function. Consequently I can ensure that any initialization needed by my view controller is performed prior to doing so.

## References

For more information on the concept of injecting services and not data, see my article on [Modern Dependency Injection in Swift](https://medium.com/better-programming/modern-dependency-injection-in-swift-952286b308be?source=friends_link&sk=ca214e3fede014d4d9528811e7204a40).

I'd also highly recommend reading [Dependency Injection Code Smell: Injecting runtime data into components](https://blogs.cuttingedge.it/steven/posts/2015/code-smell-injecting-runtime-data-into-components/) by Steven van Deursen.
