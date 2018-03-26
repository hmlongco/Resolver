# Resolver ![icon](https://user-images.githubusercontent.com/709283/32858974-cce8282a-ca12-11e7-944b-c8046156290b.png)
Swift Ultralight Dependency Injection / Service Locator framework

## The basics

Resolver is a *Dependency Injection* system that allows you to register the objects and protocols that other objects will need during the lifetime of your application.

Here, Resolver is being asked to register the type ABCService.

```
    Resolver.register { ABCService() }
```
Note that a factory closure was provided that will create an instance of ABCService when needed.

Once registered, any object can ask Resolver to provide (resolve) an object of that type.

```
    var abc: ABCService = Resolver.resolve()
```

# Why bother?

So we registered a factory, and asked Resolver to resolve it, and it worked... but why go to the extra trouble? 

Why we don't just directly instantiate an ABCService and be done with it?
```
    let abc = ABCService()
```
Well, there are several reasons why this is a bad idea, but let's start with two:

First, what happens if ABCService in turn requires other classes or objects to do its job? And what happens if those objects need references to other objects, services, and system resources?
```
    let session = XYZSession()
    let fetcher = JKLFetcher(session)
    let abc = ABCService(fetcher)
```
You're literally left with needing to construct the objects needed... to build the objects needed... to build the single instance of the object that you actually wanted in the first place.

Those additonal objects are known as *dependencies*.

Second, and worse, the constructing class now knows the internals and requirements for ABCService, and for JKLFetcher, and it also knows about XYZSession. 

It's now tightly *coupled* to the behavior and distinct implementations of all of those classes... when all it really wanted to do was talk to an ABCService.

## ViewControllers, ViewModel, and Services. Oh, my.

To demonstrate, let's use a more complex example.

Here we have a UIViewController named MyViewController that requires an instance of an XYZViewModel.

```
class MyViewController: UIViewController {
    var viewModel: XYZViewModel!
}
```

The XYZViewModel needs an instance of an object that implements a XYZFetching protocol, one that implements XYZUpdating, and it also wants access to a XYZService for good measure.

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

struct XYZService {
    private var session: XYZSessionService
    init(_ session: XYZSessionService) {
        self.session = session
    }
}

class XYZSessionService {
    // Implmentation
}

```

Note that the initializers for XYZViewModel and XYZService are each passed the objects they need to do their jobs. To use Dependency Injection lingo, this is known as *Initialization Injection* and it's the recommended approach to object construction.

## Registration

Let's use Resolver to register some classes. 

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

So, the above code shows us registering XYZViewModel, the protocols XYZFetching and XYZUpdating, the XYZService, and the XYZSessionService.

Now we've registered all of the objects our app is going to use. But what starts the process? Who resolves first? 

## The Resolution Cycle

Well, MyViewController is the one who wanted a XYZViewModel, so let's rewrite it as follows...

```
class MyViewController: UIViewController, Resolving {
    lazy var viewModel: XYZViewModel = resolver.resolve()!
}
```

Adopting the Resolving protocol injects the default resolver instance into MyViewController. Calling resolve on that instance allows it to request a XYZViewModel from Resolver. 

To use more Dependency Injection lingo, resolver was added to MyViewController using *Interface Injection*, and resolver.resolve() acts as the *Service Locator* for MyViewController.

Note that the viewModel parameter is lazy, so when it's first accessed a *Resolution Cycle* kicks off.

* Resolver infers the type of object being requested. (e.g. XYZViewModel)
* Resolver searches the registry for a registration of that type to in order to find the correct object factory.
* Resolver tells the factory to resolve.
* Resolving, the XYZViewModel factory inits an XYZViewModel, but first it needs a fetecher, an updater, and service object.
* Resolving, the XYZFetcher factory creates and returns a fetcher.
* Resolving, the XYZUpdater factory creates and returns an updater.
* Resolving, the XYZService factory creates and returns an XYZService, but first it needs an XYZSessionService.
* Resolving, the XYZSessionService factory creates and returns a session.
* The XYZService gets its XYZSessionService and inits.
* The XYZViewModel gets a XYZFetching instance, a XYZUpdating instance, and a XYZService instance and inits.

And MyViewController gets its XYZViewModel. It doesn't know the internals of XYZViewModel, nor does it know about XYZFetcher's, XYZUpdater's, XYZService's, or XYZSessionService's.

Nor does it need to. It simply asks Resolver for an instance of type T, and Resolver complies.

## Type Inference

Resolver's pretty smart, and it uses Swift type-inference to automatically detect the type of the class or struct being registered, based on the type of object returned by the factory function.

```
main.register { ABCService() } // Returns an ABCService, so we're registering an instance of ABCService
```

Resolver can also automatically infer the instance type for method parameters, as shown in the earlier XYZViewModel factory closure.

```
main.register { XYZViewModel(fetcher: resolve(), updater: resolve(), service: resolve()) }
```

In order to be initialized, XYZViewModel needs a fetcher of type XYZFetching, an updater of type XYZUpdating, and a servic of type XYZService. 

Instead of creating those objects directly, the factory method passes the buck back to Resolver, asking it to "resolve" those parameters as well.

The same chain of events occurs for every object requested during a give resolution cycle, until every dependent object has the resources it needs to be properly initialized.

Next, Resolver can automatically infer the instance type of the object being requested (resolved). 

```
    var abc: ABCService = Resolver.resolve()!
```

Finally, you can also explicity tell Resolver the type of object or protocol you want to register or resolve.

```
    Resolver.register(ABCServicing.self) { ABCService() }
    var abc = Resolver.resolve(ABCServicing.self)!
```

We'll get into why that might be useful later on.

## Better Protocol registration

Note that in our more complex example code the resolution factories for XYZFetching and XYZUpdating each returned their own object, even though both interfaces were actually implemented in the same object.

Sometimes this is what you want. 

But if not, and in order to have XYZViewModel resolve both interfaces to the same object during a given resolution cycle, you can simply replace the following lines of code...

```
main.register { XYZCombinedService() as XYZFetching }
main.register { XYZCombinedService() as XYZUpdating }
```

With these...

```
main.register { XYZCombinedService() }
.implements(XYZFetching.self)
.implements(XYZUpdating.self)
```

Now both the XYZFetching and XYZUpdating protocols are tied to the same object, and given the default scope, only one instance of XYZCombinedService will be constructed during a specific resolution cycle.

[API Documentation](https://hmlongco.github.io/Resolver/Documentation/API/Classes/Resolver.html)
