#  Resolver: Injection Strategies

## Terminology

There are five primary ways of performing dependency injection using Resolver:

1. [Interface Injection](#interface)
2. [Property Injection](#property)
3. [Constructor Injection](#constructor)
4. [Method Injection](#method)
5. [Service Locator](#locator)

The names and numbers come from the *Inversion of Control* design pattern. For a more thorough discussion, see the classic arcticle by [Martin Fowler](https://martinfowler.com/articles/injection.html).

Here I'll simply provide a brief description and an example of implementing each using Resolver.

## <a name=interface></a>1. Interface Injection

#### Definition

The first injection technique is to define a interface for the injection, and injecting that interface into the class or object using Swift extensions.

#### The Class

```
class XYZViewModel {

    lazy var fetcher: XYZFetching = getFetcher()
    lazy var service: XYZService = getService()

    func load() -> Data {
        return fetcher.getData(service)
    }

}
```

#### The Dependency Injection Code

```
extension XYZViewModel: Resolving {
    func getFetcher() -> XYZFetching { return resolver.resolve() }
    func getService() -> XYZService { return resolver.resolve() }
}

func setupMyRegistrations {
    register { XYZFetcher() as XYZFetching }
    register { XYZService() }
}
```

Note that you still want to call `resolve()` within `getFetcher()` and `getService()` , otherwise you're back to tightly-coupling the dependent classes and bypassing the resolution registration system.

#### Pros

* Lightweight.
* Hides dependency injection system from class.
* Useful for classes like UIViewController where you don't have access during the initialization process.

#### Cons

* Writing an accessor function for every service that needs to be injected.

## <a name=property></a>2. Property Injection

#### Definition

Property Injection exposes its dependencies as properties, and it's up to the Dependency Injection system to make sure everything is setup prior to any methods being called.

#### The Class

```
class XYZViewModel {

    var fetcher: XYZFetching!
    var service: XYZService!

    func load() -> Data {
        return fetcher.getData(service)
    }

}
```

#### The Dependency Injection Code

```
func setupMyRegistrations {
    register { XYZViewModel() }
        .resolveProperties { (resolver, model) in
            model.fetcher = resolver.optional() // Note property is an ImplicitlyUnwrappedOptional
            model.service = resolver.optional() // Ditto
        }
}


func setupMyRegistrations {
    register { XYZFetcher() as XYZFetching }
    register { XYZService() }
}
```

#### Pros

* Clean.
* Also fairly lightweight.

#### Cons

* Exposes internals as public variables.
* Harder to ensure that an object has been given everything it needs to do its job.
* More work on the registration side of the fence.

## <a name=constructor></a>3. Constructor Injection

#### Definition

A Constructor is the Java term for a Swift Initializer, but the idea is the same: Pass all of the dependencies an object needs through its initialization function.

#### The Class

```
class XYZViewModel {

    private var fetcher: XYZFetching
    private var service: XYZService

    init(fetcher: XYZFetching, service: XYZService) {
        self.fetcher = fetcher
        self.service = service
    }

    func load() -> Image {
        let data = fetcher.getData(token)
        return service.decompress(data)
   }

}
```

#### The Dependency Injection Code

```
func setupMyRegistrations {
    register { XYZViewModel(fetcher: resolve(), service: resolve()) }
    register { XYZFetcher() as XYZFetching }
    register { XYZService() }
}
```

#### Pros

* Ensures that the object has everything it needs to do its job, as the object can't be constructed otherwise.
* Hides dependencies as private or internal.
* Less code needed for the registration factory.

#### Cons

* Requires object to have initializer with all parameters needed.
* More boilerplace code needed in the object initializer to transfer parameters to object properties.

## <a name=method></a>4. Method Injection

#### Definition

This is listed for competeness, even though it's not a pattern that uses Resolver directly.

Method Injection is pretty much what it says, injecting the object needed into a given method.

#### The Class

```
class XYZViewModel {

    func load() -> Data {
        return fetcher.getData(service)
    }

}
```

#### The Dependency Injection Code

You've already seen it. In the load function, the service object is passed into the fetcher's getData method.

#### Pros

* Allows callers to configure the behavior of a method on the fly.
* Allows callers to construct their own behaviors and pass them into the method.

#### Cons

* Exposes those behaviors to all of the classes that use it.

#### Note

In Swift, passing a closure into a method could also be considered a form of Method Injection.

## <a name=locator></a>5. Service Locator

#### Definition

Finally, a Service Locator is basically a service that locates the resources and dependencies an object needs.

Technically, Service Locator is its own Design Pattern, distinct from Dependency Injection, but Resolver supports both and the Service Locator pattern is particularly useful when supporting view controllers and other classes where the initialization process is outside of your control. (See [Storyboards](https://github.com/hmlongco/Resolver/blob/master/Documentation/Storyboards.md).)

#### The Class

```
class XYZViewModel {

    var fetcher: XYZFetching = Resolver.resolve()
    var service: XYZService = Resolver.resolve()

    func load() -> Data {
        return fetcher.getData(service)
    }

}
```

#### The Dependency Injection Code

```
func setupMyRegistrations {
    register { XYZFetcher() as XYZFetching }
    register { XYZService() }
}
```

#### Pros

* Less code.
* Useful for classes like UIViewController where you don't have access during the initialization process.

#### Cons

* Exposes the dependency injection system to all of the classes that use it.

## Additonal Resources

This just skims the surface. For a more in-depth look at the pros and cons, see: [Inversion of Control Containers and the Dependency Injection pattern ~ Martin Fowler](https://martinfowler.com/articles/injection.html).
