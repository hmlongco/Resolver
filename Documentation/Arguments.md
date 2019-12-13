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
