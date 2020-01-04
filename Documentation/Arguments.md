#  Resolver: Arguments

## Passing arguments to a registration factory

Consider the following code:

```swift
class ViewController: UIViewController, Resolving {
    var editMode: Bool = true // set, perhaps, by calling segue
    lazy var viewModel: XYZViewModel = resolver.resolve(args: editMode)
}
```

## Arguments as Properties

The `editMode` argument passed could be set on the model as follows:

```swift
register { XYZViewModel(fetcher: resolve(), updater: resolve(), service: resolve()) }
    .resolveProperties { (resolver, model, args) in
        model.editMode = args as? Bool ?? true
    }
```
## Multiple Arguments as Properties

Pass N number of arguments of any type (Do not have to be of the same type) : 

```swift
resolver.register { (res, args) -> InjectableClass in
           //
           let firstArgument: String = res.firstArgument(from: args!)!
           let secondArgument: Int = res.secondArgument(from: args!)!
           let thirdArgument: Bool = res.thirdArgument(from: args!)!
           let fourthArguemnt: Double = res.argument(from: args!, argumentNo: 3)!
           //
           return InjectableClass(firstArgument, secondArgument, thirdArgument, fourthArguemnt)
}
```

Resolve up to five arguments (arg0...arg 5 ) of any type :

```swift
resolver.resolve(arg0: "AMS", arg1: 11, arg2: true, arg3: 3.14159, arg4: Any, arg5: 123)
}
```

Resolve with N number of arguments of any type (params: ...... )

```swift
let injectableClass: InjectableClass = resolver.resolve(params: "AMS", 11, true, 3.14159)
}
```

## Arguments used during Initialization

Or used during object construction:

```swift
register { (_, arg) -> XYZViewModel in
    let editing = (arg as? Bool ?? true)
    let updater: XYZUpdating = editing ? resolve(XYZUpdateEdit.self) : resolve(XYZUpdateAdd.self)
    return XYZViewModel(fetcher: resolve(), updater: updater, service: resolve())
}
register { XYZUpdateAdd() }
register { XYZUpdateEdit() }
```

Here we're giving XYZViewModel different object updaters, depending upon whether or not we're editing our data or adding it.

Note the use of `register { (_, arg) -> XYZViewModel in` on the first line.

In addition to using the closure factory arguments, we're also explicitly specifying the return type. Complex, multiple line factories like this one can cause Swift to lose track of the actual return type. Explicitly specifying the type clears up the confusion.
