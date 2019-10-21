#  Resolver: Introduction

## Definitions

Resolver is a Dependency Injection framework for Swift that supports the Inversion of Control design pattern.

Computer Science definitions aside, Dependency Injection pretty much boils down to:

| **Giving an object the things it needs to do its job.**

Dependency Injection allows us to write code that's loosely coupled, and as such, easier to reuse, to mock, and  to test.

## Quick Example

Here's an object that needs  to talk to an NetworkService.

```
class MyViewModel {
    let service = NetworkService()
    func load() {
        let data = service.getData()
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
        let data = service.getData()
    }
}
```

MyViewModel now depends on the network service being set beforehand, as opposed to directly instantiating a copy of NetworkService itself.

Further, MyViewModel is now using a protocol named NetworkServicing, which in turn defines a  `getData()` method.

Those two changes allow us to meet all of the goals mentioned above.

Pass the right implementation of NetworkServicing to MyViewModel, and the data can be pulled from the network, from a cache, from a test file on disk, or from a pool of mocked data.

Okay, fine. But doesn't this approach just kick the can further down the road?

How do I get MyViewModel and how does MyViewModel get the right version of NetworkServicing? Don't I have to create it and set its property myself?

Well, you could, but the better answer is to use Dependency Injection.

## Registration

Dependency Injection works in two phases: *Registration* and *Resolution*.

Registration consists of registering the classes and objects we're going to need,  as well as providing a *factory* closure to create an instance of one when needed.

```
Resolver.register { NetworkService() as NetworkServicing }

Resolver.register { MyViewModel() }.resolveProperties { (_, model) in
    model.service = optional() // note NetworkServicing was defined as an ImplicitlyUnwrappedOptional
}
```

The above looks a bit complex, but it's actually fairly straightforward.

First, we registered a factory (closure) that will create an instance of NetworkService when needed. The type being registered is [automatically inferred](Types.md) using the result type returned by the factory.

Hence we're creating a NetworkService, but we're acutally registering the protocol NetworkServicing.

Similarly, we registered a factory to create MyViewModel's when needed, and we also added a resolveProperties closure to [resolve](Resolving.md) its service property.

## Resolution

Once registered, any object can ask Resolver to provide (resolve) an object of that type.

```
var viewModel: MyViewModel = Resolver.resolve()
```

## Why bother?

So we registered a factory, and asked Resolver to resolve it, and it worked... but why go to the extra trouble?

Why we don't just directly instantiate  MyViewModel and be done with it?
```
var viewModel = MyViewModel()
viewModel.service = NetworkService()
```
Well, there are several reasons why this is a bad idea, but let's start with two:

First, what happens if NetworkService in turn required other classes or objects to do its job? And what happens if those objects need references to other objects, services, and system resources?

```
var viewModel = MyViewModel()
viewModel.service = NetworkService(TokenVendor.token(AppDelegate.seed))
```

You're literally left with needing to construct the objects needed... to build the objects needed... to build the single instance of the object that you actually wanted in the first place.

Those additonal objects are known as *dependencies*.

Second, and worse, the constructing class now knows the internals and requirements for MyViewModel, and for NetworkService, and it also knows about TokenVendor and its requirements.

It's now tightly *coupled* to the behavior and distinct implementations of all of those classes... when all it really wanted to do was talk to a MyViewModel.

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
    // Implmentation
}

class XYZCombinedService: XYZFetching, XYZUpdating {
    private var session: XYZSessionService
    init(_ session: XYZSessionService) {
        self.session = session
    }
    // Implmentation
}

struct XYZService {
    // Implmentation
}

class XYZSessionService {
    // Implmentation
}
```

Note that the initializers for XYZViewModel and XYZCombinedService are each passed the objects they need to do their jobs. To use Dependency Injection lingo, this is known as [Initialization or Constructor Injection](Injection.md#constructor) and it's the recommended approach to object construction.

## Registration

Let's use Resolver to register these classes.

Here we're extending the base Resolver class with the ResolverRegistering protcol, which pretty much just tells Resolver that we've added the registerAllServices() function.

The `registerAllServices` function is automatically called by Resolver the first time it's asked to resolve a service, in effect performing a one-time initialization of the resolution system.

```
extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register { XYZViewModel(fetcher: resolve(), updater: resolve(), service: resolve()) }
        register { XYZCombinedService(resolve()) }
            .implements(XYZFetching.self)
            .implements(XYZUpdating.self)
        register { XYZService() }
        register { XYZSessionService() }
    }
}
```

So, the above code shows us registering XYZViewModel, the protocols XYZFetching and XYZUpdating, the XYZCombinedService, the XYZService, and the XYZSessionService.

[Learn more about Registration](Registration.md)

## Resolution

Now we've registered all of the objects our app is going to use. But what starts the process? Who resolves first?

Well, MyViewController is the one who wanted a XYZViewModel, so let's rewrite it as follows...

```
class MyViewController: UIViewController, Resolving {
    lazy var viewModel: XYZViewModel = resolver.resolve()
}
```

Adopting the Resolving protocol injects the default resolver instance into MyViewController (Interface Injection). Calling resolve on that instance allows it to request a XYZViewModel from Resolver.

Resolver processes the request, finds the right factory to make a XYZViewModel, and tells it to do so. 

The XYZViewModel factory, in turn, triggers the resolution of the types that *it* needs (XYZFetching, XYZUpdating, and XYZService), and so on, down the chain. Eventually, the XYZViewModel factory gets everything it needs, returns the correct instance, and MyViewController gets its view model.

MyViewController doesn't know the internals of XYZViewModel, nor does it know about XYZFetcher's, XYZUpdater's, XYZService's, or XYZSessionService's.

Nor does it need to. It simply asks Resolver for an instance of type T, and Resolver complies.

Learn more about [Resolving](Resolving.md) and the [Resolution Cycle](Cycle.md).

## Mocking

Okay, you might think. That's pretty cool, but earlier you mentioned other benefits, like testing and mocking. What about those?

Consider the following change to the above code:

```
extension Resolver {
    static func registerAllServices() {
        register { XYZViewModel(fetcher: resolve(), updater: resolve(), service: resolve()) }
        register { XYZCombinedService(resolve()) }
            .implements(XYZFetching.self)
            .implements(XYZUpdating.self)
        register { XYZService() }
        register { XYZSessionService() }

        #if DEBUG
        register { XYZMockSessionService() as XYZSessionService }
        #end
    }
}
```

This is just one approach, but it illustrates the concept. Now when MyViewController asks for a XYZViewModel, it gets one. The resolved XYZViewModel, in turn has its fetcher, updater, and service.

However, if we're in debug mode the fetcher and updater now have a XYZMockSessionService, which could pull mock data from embedded files instead of going out to the server as normal.

And both MyViewController and XYZViewModel are none the wiser.

## Testing

Same for unit testing. Add something like the following to the unit test code.

```
let data = ["name":"Mike", "developer":true]
register { XYZTestSessionService(data) as XYZSessionService }
let viewModel: XYZViewModel = Resolver.resolve()
```

Now your unit and integration tests for XYZViewModel as using XYZTestSessionService, which povides stable, known data to the model.

Do it again.
```
let data = ["name":"Boss", "developer":false]
register { XYZTestSessionService(data) as XYZSessionService }
let viewModel: XYZViewModel = Resolver.resolve()
```

And you can now easily test different scenarios.
