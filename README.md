# Resolver ![icon](https://user-images.githubusercontent.com/709283/32858974-cce8282a-ca12-11e7-944b-c8046156290b.png)
Swift Ultralight Dependency Injection / Service Locator framework

## The Basics

Resolver is a Dependency Injection system that allows you to register the objects and protocols that other objects will need during the lifetime of your application.

Once registered, any object can request a registered object and a fully initialized instance will be provided to it.

```
    // Register a service...
    Resolver.register { ABCService() }
    
    // Request an instance...
    var abc: ABCService = Resolver.resolve()
```

But what happens if ABCService in turn requires other classes or objects to do its job? And what happens if those objects need references to other objects, services, and system resources?

You're literally left with needing to construct the objects needed... to build the objects needed... to build the single instance of the object that you actually wanted in the first place.

And that's where the power of a Dependency Injection framework comes into play.

## ViewModels and ViewControllers

To demonstrate, let's use a more complex example.

Here we have a UIViewController named MyViewController that requires an instance of an XYZViewModel.

```
class MyViewController: UIViewController {

    var viewModel: XYZViewModel!
    
}
```

The XYZViewModel needs an instance of an object that implements a XYZFetching protocol, one that implements XYZUpdating, and it also wants to use a XYZService for good measure.

The XYZService, in turn, needs a reference to an XYZSessionService to do it's job.

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

So let's register some classes. 

Here we're extending the base Resolver class with the ResolverRegistering protcol, which basically just means that we've added the registerAllServices() function.

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

register { XYZSessionService() }

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

So we have all of our object registered. But what starts the process? Let's rewrite MyViewController as follows...

```
class MyViewController: UIViewController, Resolving {

    lazy var viewModel: XYZViewModel = resolver.resolve()!
    
}
```

Adopting the Resolving protocol allows MyViewController to request a XYZViewModel from Resolver. Resolver infers the type of object being requests, and uses the list of pre-registered object factories to construct an XYZViewModel and return it to the view controller.

## Better Registration

Note the resolution factories for XYZFetching and XYZUpdating demonstrated above eac returnh their own object, even though interfaces are implemented in the same object.

To have XYZViewModel resolve both interfaces to the same object in the same graph you could do the following:

```
extension Resolver: ResolverRegistering {

public static func registerAllServices() {

// Register XYZService and cache result for lifetime of application
main.register { XYZService() }
    .scope(application)

// Register instance with injected parameters
main.register { XYZViewModel(fetcher: resolve(), updater: resolve(), service: resolve()) }

// Register service instance that implements both protocols 
main.register { XYZCombinedService() }
.implements(XYZFetching.self)
.implements(XYZUpdating.self)

}

}
```


[API Documentation](https://hmlongco.github.io/Resolver/Documentation/API/Classes/Resolver.html)
