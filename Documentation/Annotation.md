#  Resolver: Annotation

Another common Dependency Injection strategy is annotation: adding comments or other metadata to the code which indicates that the following service needs to be resolved by the dependency injection system.

This is commonly done on Android using Dagger 2, and we can now do something similar on iOS.

## Property Wrappers

Resolver now supports resolving properties using the new property wrapper syntax in Swift 5.1.

```
class BasicInjectedViewController: UIViewController {
    @Injected var service: XYZService
}
```
Just add the Injected property wrapper and your dependencies will be resolved automatically and instantiated immediately, ready and waiting for use.

**Note that you still need to [register](Registration.md) any class or classes that you need to resolve.**

Also note that as long as you compile with Swift 5.1, **property wrappers work on earlier versions of iOS (11, 12)**. They're not just limited to iOS 13.

The Injected property wrapper will automatically instantiate objects using the current Resolver root container, exactly as if you'd done `var service: XYZService = Resolver.resolve()`. See instructions below on how to specify a different container.

###  Lazy Injection

Resolver also has a LazyInjected property wrapper. Unlike using Injected, lazily injected services are not resolved until the code attempts to access the wrapped service.
```
class NamedInjectedViewController: UIViewController {
    @LazyInjected var service: XYZNameService
    func load() {
        service.load() // service will be resolved at this point in time
    }
}
```
Note that LazyInjected is a mutating property wrapper. As such it can only be used in class instances or in structs when the struct is mutable.

###  Weak Lazy Injection

Resolver also has a WeakLazyInjected property wrapper. Like LazyInjected, services are not resolved until the code attempts to access the wrapped service.
```
class NamedInjectedViewController: UIViewController {
    @WeakLazyInjected var service: XYZNameService
    func load() {
        service.load() // service will be resolved at this point in time
    }
}
```
Note that LazyInjected is a mutating property wrapper. As such it can only be used in class instances or in structs when the struct is mutable.

### Named injection

You can use named service resolution using the `name`  property wrapper initializer as shown below.

```
class NamedInjectedViewController: UIViewController {
    @Injected(name: "fred") var service: XYZNameService
}
```
You can also update the name in code and 'on the fly' using @LazyInjected.
```
class NamedInjectedViewController: UIViewController {
    @LazyInjected var service: XYZNameService
    var which: Bool
    override func viewDidLoad() {
        super.viewDidLoad()
        $service.name = which ? "fred" : "barney"
    }
}
```
If you go this route just make sure you specify the name *before* accessing the injected service for the first time.

###  Optional injection

An annotation is available that supports optional resolving. If the service is not registered, then the value will be nil, otherwise it will be not nil:
```
class InjectedViewController: UIViewController {
    @OptionalInjected var service: XYZService?
    func load() {
        service?.load()
    }
}
```

### Custom Containers

You can specify and resolve custom containers using Injected. Just define your custom container...

```
extension Resolver {
    static var custom = Resolver()
}
```
And specify it as part of the Injected property wrapper initializer.
```
class ContainerInjectedViewController: UIViewController {
    @Injected(container: .custom) var service: XYZNameService
}
```
As with named injection, with LazyInjected you can also dynamically specifiy the desired container.
```
class NamedInjectedViewController: UIViewController {
    @LazyInjected var service: XYZNameService
    var which: Bool
    override func viewDidLoad() {
        super.viewDidLoad()
        $service.container = which ? "main" : "test"
    }
}
```

### More Information

I've written quite a bit more on developing the Injected property wrapper. You can find more information on Injected and property wrappers in my article, [Swift 5.1 Takes Dependency Injection to the Next Level](https://medium.com/better-programming/taking-swift-dependency-injection-to-the-next-level-b71114c6a9c6) on Medium.
