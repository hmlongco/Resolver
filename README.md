# Resolver ![icon](https://user-images.githubusercontent.com/709283/32858974-cce8282a-ca12-11e7-944b-c8046156290b.png)
Swift Ultralight Dependency Injection / Service Locator framework

## The Basics

Resolver is a Dependency Injection system that allows you to register the objects and protocols that other objects will need during the lifetime of your application.

Here, Resolver is being asked to register the type ABCService.

```
    Resolver.register { ABCService() }
```
Note that a factory closure was provided that will create an instance of ABCService when needed.

Once registered, any object can ask Resolver to provide (resolve) an object of that type.

```
    var abc: ABCService = Resolver.resolve()
```

# Why Bother?

So we registered a factory, and asked Resolver to resolve it, and it worked... but why go to the extra trouble? 

Why we don't just instantiate an ABCService and be done with it?
```
    let abc = ABCService()
```
You could do so, but that adds its own problems to the mix.

First, what happens if ABCService in turn requires other classes or objects to do its job? And what happens if those objects need references to other objects, services, and system resources?
```
    let abc = ABCService(JKLFetcher(XYZSession()))
```
You're literally left with needing to construct the objects needed... to build the objects needed... to build the single instance of the object that you actually wanted in the first place.

Worse, the constructing class now knows the internals and requirements for ABCService, and for JKLFetcher, and it also knows about XYZSession. It's now tightly coupled to the behavior and implementations of all of those classes... when all it really needed was an ABCService.

There are other reasons, but let's run with these two for awhile.

## ViewModels and ViewControllers

To demonstrate, let's use a more complex example.

Here we have a UIViewController named MyViewController that requires an instance of an XYZViewModel.

```
class MyViewController: UIViewController {
    var viewModel: XYZViewModel!
}
```

The XYZViewModel needs an instance of an object that implements a XYZFetching protocol, one that implements XYZUpdating, and it also wants to use a XYZService for good measure.

The XYZService, in turn, needs a reference to an XYZSessionService to do its job.

```
class XYZViewModel {
    private var fetcher: XYZFetching
    private var updater: XYZUpdating
    private var service: XYZService
    
    init(fetcher: XYZFetching, updater: XYZUpdating, service: XYZService) {
        self.fetcher = fetcher
        self.updater = updater
        self.service = service
    }
}

class XYZCombinedService: XYZFetching, XYZUpdating {
    // Implements protocols
}

class XYZService {
    private var session: XYZSessionService
    init(_ session: XYZSessionService) {
        self.session = session
    }
}

class XYZSessionService {
    // Implmentation
}

```

## Registration

So let's use Resolver to register some classes. 

Here we're extending the base Resolver class with the ResolverRegistering protcol, which pretty much just means that we've added the registerAllServices() function.

"registerAllServices" is automatically called by Resolver the first time it's asked to resolve a service, in effect performing a one-time initialization of the resolution system.

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
```

So the code above shows us registering XYZViewModel, the protocols XYZFetching and XYZUpdating, the XYZService, and the XYZSessionService.

## Type Inference

Resolver automatically infers the type of the class or struct being registered based on the type of object returned by the factory function.

Resolver can also automatically infer the instance type of the object being requested, as shown in the XYZViewModel factory closure. 

```
main.register { XYZViewModel(fetcher: resolve(), updater: resolve(), service: resolve()) }
```

In order to be initialized, XYZViewModel needs a fetcher of type XYZFetching, an updater of type XYZUpdating, and a servic of type XYZService. Instead of creating those objects directly, the factory method passes the buck back to Resolver, asking it to "resolve" those parameters as well.

The same chain of events occurs for every object requested during a resolution pass, until every dependent object has the resources it needs to be properly initialized.

## Resolution

So we have all of our objects registered. But what starts the process? Who resolves first? 

Well, MyViewController is the one who wants a XYZViewModel, so Let's rewrite it as follows...

```
class MyViewController: UIViewController, Resolving {
    lazy var viewModel: XYZViewModel = resolver.resolve()!
}
```

Adopting the Resolving protocol allows MyViewController to request a XYZViewModel from Resolver. 

Or to put it another way, resolver is the *Service Locator* for MyViewController.

## The Resolution Cycle

Note that the viewModel parameter is lazy. 

So when it's first accessed, a *Resolution Cycle* kicks off.

* Resolver infers the type of object being requested. (e.g. XYZViewModel)
* Resolver searches the registry for that type to in order to find the correct object factory.
* Resolver tells the factory to resolve.
* Resolving, the XYZViewModel factory inits an XYZViewModel, but first it needs a fetecher, an updater, and service object.
* Resolving, the XYZFetcher factory creates and returns a fetcher.
* Resolving, the XYZUpdater factory creates and returns an updater.
* Resolving, the XYZService factory creates and returns an XYZService, but first it needs an XYZSessionService.
* Resolving, the XYZSessionService factory creates and returns a session.
* The XYZService gets its XYZSessionService and inits.
* The XYZViewModel gets a XYZFetching instance, a XYZUpdating instance, and a XYZService instance and inits.

And MyViewController gets its XYZViewModel. It doesn't know the internals of XYZViewModel, nor does it know about XYZFetcher's, XYZUpdater's, XYZService's, or XYZSessionService's.

Nor does it need to.

## Better Registration

Note the resolution factories for XYZFetching and XYZUpdating demonstrated above each return their own object, even though both interfaces were implemented in the same object.

To have XYZViewModel resolve both interfaces to the same object during a given resolution cycle, you could...

```
// Replace the following lines of code...
main.register { XYZCombinedService() as XYZFetching }
main.register { XYZCombinedService() as XYZUpdating }

// With this...
main.register { XYZCombinedService() }
.implements(XYZFetching.self)
.implements(XYZUpdating.self)
```

Now both the XYZFetching and XYZUpdating protocols are tied to the same object, and given the default scope, only one instance of XYZCombinedService will be constructed during a specific resolution cycle.

[API Documentation](https://hmlongco.github.io/Resolver/Documentation/API/Classes/Resolver.html)
