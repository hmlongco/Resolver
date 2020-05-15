#  Resolver: Arguments

## Resolver 1.2 and Multiple Argument Support

Resolver 1.2 changed how arguments are passed to the registration factory order to provide better support for passing and handling both single and multiple arguments.  This is, unfortunately, a breaking change to Resolver, but as the end result is much cleaner code I think it's worth it. 

**This change only affect factories that expected a passed argument, and that expected that argument to be of type Any?.**

## Passing arguments to a registration factory

Consider the following code:

```swift
class ViewController: UIViewController, Resolving {
    var editMode: Bool = true // set, perhaps, by calling segue
    lazy var viewModel: XYZViewModel = resolver.resolve(args: editMode)
}
```

This is passing a single argument to Resolver through the `args` parameter, which in turn will provide it to the registration factory accessible from a custom type, `Resolver.Args`.

## Initialization Arguments

The `editMode` argument passed in `resolve` could be set on the model in the registration factory as follows:

```swift
register { (_, arg) in 
    XYZViewModel(editMode: arg()!)
}
```
Here we're using the new callAsFunction feature from Swift 5.2 to access our single passed argument and return it as the inferred type. 

You could also use the `subscript` syntax provided by `Resolver.Args` to access the first argument directly. (You will also need to do this if your project isn't yet building with Swift 5.2). 
```swift
register { (_, args) in 
    XYZViewModel(editMode: args[0]!)
}
```
Note that in both cases Resolver is attempting to infer the argument type based on the type of the expected value. The result is returned as an optional which is why it's explicitly unwrapped in both examples.

Prior to Resolver 1.2, you would have been required to cast the type manually from `Any?` to `Bool`.

```swift
register { (_, arg) in 
    XYZViewModel(editMode: arg as? Bool ?? true)
}
```

## Passing and Handling Multiple Arguments

Handling multiple arguments is equally easy, and should be obvious given the subscript syntax you've already seen:
```swift
register { (_, args) in 
    XYZViewModel(editMode: args[0]!, name: args[1]!)
}
```
Again, both types are automatically inferred.

Pass the arguments to the Resolver registration factory using the following syntax:
```swift
class ViewController: UIViewController, Resolving {
    lazy var viewModel: XYZViewModel = resolver.resolve(arg0: true, arg1: "Editing")
}
```
Resolver supports passing up to eight arguments as `arg0` through `arg7`. 

Note that arguments are passed postionally, so be careful when passing and unpacking values. If you get a crash, double-check the order and type of your passed arguments.
## Arguments as Properties

An `editMode` property could also be set on a model as follows:

```swift
register { XYZViewModel(fetcher: resolve(), updater: resolve(), service: resolve()) }
    .resolveProperties { (resolver, model, arg) in
        model.editMode = arg()!
    }
```
The `subscript` syntax works here as well, for both single and multiple arguments. This too is a breaking change for Resolver 1.2 as the previous `args` argument passed to `resolveProperties` was `Any?`.

## Using Arguments as Factory Specifiers

It's possible to use passed arguments to change how Resolver will resolve a certain type:

```swift
register { (_, arg) -> XYZViewModel in
    let editing: Bool = arg() ?? true
    let updater: XYZUpdating = editing ? resolve(XYZUpdateEdit.self) : resolve(XYZUpdateAdd.self)
    return XYZViewModel(fetcher: resolve(), updater: updater, service: resolve())
}
register { XYZUpdateAdd() }
register { XYZUpdateEdit() }
```

Here we're giving XYZViewModel different object updaters, depending upon whether or not we're editing our data or adding it.

Note the use of `register { (_, arg) -> XYZViewModel in` on the first line.

In addition to using the closure factory arguments, we're also explicitly specifying the return type. Complex, multiple line factories like this one can cause Swift to lose track of the actual return type. Explicitly specifying the type clears up the confusion.

## The Case AGAINST Arguments
Resolver supports handling single and multiple arguments because it's needed from time to time, and because people have asked for it to do so.

Unfortunately, there are still issues with Resolver's implmentation: 

1. The biggest problem is that it erases the type information between the caller and the registration factory.
2. Since types are inferred, most of the time it requires explicit unwrapping of the resulting arguments.
3. Positional arguments are highly prone to failure should the object initializer's type signature change.

And all of which goes against my viewpoint that injection exists to build the object class hierarchy, NOT to pass data. 

If an object requires configuration I'd do something like the following....
```
class DummyViewModel {
    func configure(name: String, mode: Int) { }
}

class DummyViewController: UIViewController {

    var name: String!
    var mode: Int = 0

    @Injected var viewModel: DummyViewModel

    override func viewDidLoad() {
        super.viewDidLoad()
        someSetup()
        viewModel.configure(name: name, mode: mode)
    }
}
```
Type information is preserved. Argument order is maintained. Forced unwrapping of arguments is not required.

Plus I now have the added benefit of being able to control exactly when and where in the code I call my configuration function (load function, etc.). Consequently I can ensure that any initialization needed by my view controller is performed prior to doing so.
