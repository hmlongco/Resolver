#  Resolver: Named Instances

## Why name a registration?

Because named registrations and resolutions let you change the behavior of the app.

## Example: Named Value Types

You can register value types and parameters for later resolution. However, since Resolver registers object by type, the only way to tell one `String` from another `String` is to name it.

```swift
register(name: "appKey") { "12345" }
register { XYZSessionService(key: resolve(name: "appKey")) }
```

The first line registers a String named `appKey`.

The factory in the second line resolves a String parameter named `appKey`, and passes it to the `XYZSessionService` initialization function.

This is a good way to get authentication keys, application keys, and other values to the objects that need them. 

## Name Spaces

Resolver 1.3 adds a `Name` space to Resolver similar to that of `Notificiations.Name`.  Registering a name lets you use Xcode's autocompletion feature for registrations and to resolve named instances and ensures that you don't accidentally use "fred" in one place, "Fred" in another, and "Freddy" somewhere else.

You define your own names as follows:

```swift
extension Resolver.Name {
    static let fred = Self("Fred")
    static let barney = Self("Barney")
}
```
Once defined they can be used just like any other `name` string parameter.
```swift
register(name: .fred) { XYZServiceFred() as XYZServiceProtocol }
register(name: .barney) { XYZServiceBarney() as XYZServiceProtocol }

let service: XYZServiceProtocol = resolve(name: .fred)
```
Or...
```swift
@Injected(name: .barney) var service: XYZServiceProtocol
```
You can still use `String` to register and resolve your instances, though raw string paramaters will probably become deprecated in a future instance of Resolver. 


## Example: Mocking Data

Consider the following set of registrations.

```swift
extension Resolver.Name {
    static let data = Self("data")
    static let mock = Self("mock")
}

register { resolve(name: Resolver.Name(Bundle.main.infoDictionary!["mode"] as! String)) as XYZServicing }
register(name: .data) { XYXService() as XYZServicing }
register(name: .mock) { XYXMockService() as XYZServicing }
```

We've registered the XYZServicing protocol three times, one without a name, one with the name space `.data`, and the other with the name space `.mock`.

The nameless registration, however, gets a string from the app's info.plist and asks Resolver to resolve an instance with the proper type and with the proper name.

Let's see it in use by a client.

```swift
@Injected var service: XYZServicing
```

The client just asks Resolver for a service.

Behind the scenes, however, and depending upon how the app is compiled and the "mode" value is set in the app's plist, one build will get actual data, while the other build will get mock data.

And as long as XYXMockService complies with the XYZServicing protocol, the client doesn't care.

Nor should it.

One final note here is that we registered `Resolver.Name` instances, but we passed `mode` as a `String`. This works because `Resolver.Name` supports the `ExpressibleByStringLiteral` protocol and will automatically promote the string into a `Name`.

## Example: Changing Behavior

Now, consider the next pair of registrations:

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
