#  Resolver: Introduction

## Definitions

Resolver is Dependency Injection framework for Swift that supports the Inversion of Control design pattern.

Computer Science definitions aside, Dependency Injection pretty much boils down to:

| **Giving an object the things it needs to do its job.**

Dependency Injection allows us to write code that's loosely coupled, and as such, easier to reuse, to mock, and  to test.

## Quick Example

Here's an object that needs  to talk to an NetworkService.

```
class MyViewModel {
    let service = NetworkService()
    func load() {
        let data = NetworkService.getData()
    }
}
```

This class is considered to be *tightly coupled* to its dependency, NetworkService.

The problem is that MyObject will *always* create it's own service, of type NetworkService, and that's it.

But what if at some point we want MyViewModel to pull its data from a disk instead? What if we want to reuse MyViewModel somewhere else in the code, or in another app, and have it pull different data?

What if we want to mock the results given to MyViewModel for testing?

Or simply have the app run completely on mocked data for QA purposes?

## Injection

Now, consider an object that depends upon an instance of NetworkService being passed to it, using what us DI types term *Property Injection*.

```
class MyViewModel {
    var service: NetworkServicing!
    func load() {
        let data = NetworkService.getData()
    }
}
```

MyViewModel now depends on the network service being set beforehand, as opposed to directly instantiating a copy of NetworkService itself.

Further, MyViewModel is now using a protocol named NetworkServicing, which in turn defines a  `getData()` method.

Those two changes allow us to meet all of the goals mentioned above.

Pass the right implementation of NetworkServicing to MyViewModel, and the data can be pulled from the network, from a cache, from a test file on disk, or from a pool of mocked data.

## Containers

Okay, fine. But doesn't this approach just kick the can further down the road?

How does MyViewModel get the right version of NetworkServicing?

Here, Resolver is being asked to register the type ABCService.

```
Resolver.register { ABCService() }
```
Note that a factory closure was provided that will create an instance of ABCService when needed.

Once registered, any object can ask Resolver to provide (resolve) an object of that type.

```
var abc: ABCService = Resolver.resolve()
```

## Why bother?

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

Let's use Resolver to register these classes.

Here we're extending the base Resolver class with the ResolverRegistering protcol, which pretty much just tells Resolver that we've added the registerAllServices() function.

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

[Learn more about Registration](Registration.md)

## Resolving

Now we've registered all of the objects our app is going to use. But what starts the process? Who resolves first?

Well, MyViewController is the one who wanted a XYZViewModel, so let's rewrite it as follows...

```
class MyViewController: UIViewController, Resolving {
    lazy var viewModel: XYZViewModel = resolver.resolve()
}
```

Adopting the Resolving protocol injects the default resolver instance into MyViewController. Calling resolve on that instance allows it to request a XYZViewModel from Resolver.

Resolver processes the request, returns the correct instance, and MyViewController gets its XYZViewModel.

It doesn't know the internals of XYZViewModel, nor does it know about XYZFetcher's, XYZUpdater's, XYZService's, or XYZSessionService's.

Nor does it need to. It simply asks Resolver for an instance of type T, and Resolver complies.

[Learn more about Resolving](Resolving.md)

