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
Just add the Injected keyword and your dependencies will be resolved automatically.

**Note that you still need to [register](Registration.md) any class or classes that you need to resolve.**

Also note that as long as you compile with Swift 5.1, **property wrappers work on earlier versions of iOS (11, 12)**. They're not just limited to iOS 13.

### Named injection

You can use named service resolution using the `name`  property wrapper initializer as shown below.

```
class NamedInjectedViewController: UIViewController {
    @Injected(name: "fred") var service: XYZNameService
}
```
Or you can do it in code 'on the fly'.
```
class NamedInjectedViewController: UIViewController {
    @Injected var service: XYZNameService
    var which: Bool
    override func viewDidLoad() {
        super.viewDidLoad()
        $service.name = which ? "fred" : "barney"
    }
}
```
If you choose the later route, just make sure you specify the name *before* accessing the injected service for the first time.

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

### More Information

I've written quite a bit more on developing the Injected property wrapper. You can find more information on Injected and property wrappers in my article, [Swift 5.1 Takes Dependency Injection to the Next Level](https://medium.com/better-programming/taking-swift-dependency-injection-to-the-next-level-b71114c6a9c6) on Medium.
