#  Resolver: Named Instances

## Why Name a Registration?

Because named registrations and resolutions let you change the behavior of the app and determine just which service or value should be resolved for a given type.

Dependency Injection is powerful tool, but named registrations take the entire concept to an entriely different level.

## Registering a Name

Resolver 1.3 adds a `Name` space to Resolver similar to that of `Notificiations.Name`.  Registering a name lets you use Xcode's autocompletion feature for registrations and to resolve named instances and also ensures that you don't accidentally use "fred" in one place, "Fred" in another, and "Freddy" somewhere else.

You define your own names by extending `Resolver.Name` as follows:

```swift
extension Resolver.Name {
    static let fred = Self("Fred")
    static let barney = Self("Barney")
}
```
Once defined your names can be used in the `name` parameter  when registering services. Here we define two instances of the same protocol, distinguished by name.
```swift
register(name: .fred) { XYZServiceFred() as XYZServiceProtocol }
register(name: .barney) { XYZServiceBarney() as XYZServiceProtocol }
```
Once defined and registered, names can be used during the resolution process to pick just which version of the service you desire.
```swift
let service: XYZServiceProtocol = resolve(name: .fred)
// or
@Injected(name: .barney) var service: XYZServiceProtocol
```

## Using Named Value Types

In addition to services you can also register value types and parameters for later resolution. However, since Resolver registers objects and values based on type inference, the only way to tell one `String` from another `String` is to name it.

We start once again by defining the names we want to use, in this case `appKey` and `token`.

```swift
extension Resolver.Name {
    static let appKey = Self("appKey")
    static let token = Self("token")
}
```
We then register some strings using our `.appKey` and `token` names.
```swift
register(name: .appKey) { "12345" }
register(name: .token) { "123e4567-e89b-12d3-a456-426614174000" }
```
Which can then be used when we resolve our services. The following code shows how a factory resolves a String parameter named `.appKey`, which passes the resulting string value to the `XYZSessionService` initialization function.
```swift
register { XYZSessionService(key: resolve(name: .appKey)) }
```

This is a good way to get authentication keys, application keys, and other values to the objects that need them. 

## Mocking Data

We can also use names to control access to mocked data. Consider the following set of registrations.

```swift
extension Resolver.Name {
    static let data = Self("data")
    static let mock = Self("mock")
}

register(name: .data) { XYXService() as XYZServicing }
register(name: .mock) { XYXMockService() as XYZServicing }

register { resolve(name: .name(fromString: Bundle.main.infoDictionary!["mode"] as! String)) as XYZServicing }

```

Here we've registered the XYZServicing protocol three times:  once with the name space `.data`, and then again version with the name space `.mock`. The third registration, however, has no name. 

Instead, it gets a string from the app's info.plist and asks Resolver to resolve an instance with the proper type and with the proper name.

Let's see it in use by a client.

```swift
@Injected var service: XYZServicing
```

The client just asks Resolver for an instance of `XYZServicing`.

Behind the scenes, however, and depending upon how the app is compiled and how the "mode" value is set in the app's plist, one build will get actual data, while the other build will get mock data.

And as long as XYXMockService complies with the XYZServicing protocol, the client doesn't care.

Nor should it.

One final note here is that we registered `Resolver.Name` instances, but in our factory we converted `mode` into a `Name` based on the value of the string we pulled from the plist. Just be careful when you're doing this and make sure your passed strings actually match names actually registered in the app.

## Changing Behavior On The Fly

Finally, consider the next pair of registrations:

```swift
extension Resolver.Name {
    static let add = Self("add")
    static let edit = Self("edit")
}

register(name: .add) { XYZViewModelAdding() as XYZViewModelProtocol }
register(name: .edit) { XYZViewModelEditing() as XYZViewModelProtocol }
```

Here we're registering two instances of the same protocol, `XYZViewModelProtocol`.

But one view model appears to be specific to adding things, while the other's behavior leans more towards editing.


```swift
class ViewController: UIViewController, Resolving {
    var editMode: Bool = true // set, perhaps, by calling segue
    lazy var viewModel: XYZViewModelProtocol = resolver.resolve(name: editMode ? .edit : .add)!
}
```

Now the view controller gets the proper view model for the job. The `lazy var` ensures that the viewModel resolution doesn't occur until after the viewController is instantiated and `prepareForSegue` has had a chance to correctly set `editMode`.

If you're using Resolver's property wrappers for injection, you can also do the same with `@LazyInjected`.

```swift
class NamedInjectedViewController: UIViewController {
    var editMode: Bool // set, perhaps, by calling segue
    @LazyInjected var viewModel: XYZViewModelProtocol
    override func viewDidLoad() {
        super.viewDidLoad()
        $viewModel.name = editMode ? .edit : .add
        viewModel.load()
    }
}
```
Again, just make sure you set the property name *before* using the wrapped `viewModel` for the first time.

## Using String Literals and String Variables

Name spaces are better than simple string literals. Use them.

That said, you should be aware that `Name` supports the `ExpressibleByStringLiteral` protocol, which means that you can also use a string *literal* to register and resolve your instances (e.g. `resolve(name: "Fred")`). 

String *variables*, however, are *not* automatically converted. If you're trying to translate a string variable to a `Name`, you either need to initialize it directly `Resolver.Name(myString)`, or do as we did in a previous example using the `.name(fromString: myString)` syntax.

```swift
    viewModel = resolver.optional(name: .name(fromString: type))
```

Be aware that string literal support exists primarily for backwards compatibility with earlier versions of Resolver and that raw string paramaters will probably become deprecated in a future instance of Resolver. 

*Name spaces are based on a PR concept submitted by [Artem K./DesmanLead](https://github.com/DesmanLead).*
