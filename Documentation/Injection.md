#  Resolver: Injection Strategies

## Terminology

There are four primary ways of performing dependency injection using Resolver:

1. [Interface Injection](#interface)
2. [Property Injection](#property)
3. [Constructor Injection](#constructor)
4. [Service Locator](#locator)

The names and numbers come from the *Inversion of Control* design pattern. For a more thorough discussion, see the classic arcticle by [Martin Fowler](https://martinfowler.com/articles/injection.html).

Here I'll simply provide a brief description and an example of implementing each using Resolver.

## 1. Interface Injection<a name=interface></a>

#### Definition

The first injection technique is to define a interface for the injection, and injecting that interface into the class or object using Swift extensions.

#### The Class

```
class MyViewController: UIViewController {
    lazy var viewModel = makeViewModel()
}
```

#### The Factory

```
extension MyViewController: Resolving {
    func makeViewModel() -> XYZViewModel { return resolver.resolve() }
}
```

## 2. Property Injection<a name=property></a>

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

#### The Factory

```
register { XYZViewModel()
    .resolveProperties { (resolver, model) in
        model.fetcher = resolver.optional()
        model.service = resolver.optional()
    }
}
```

## 3. Constructor Injection<a name=constructor></a>

#### Definition

A Constructor is the Java term for a Swift Initializers, but the idea is the same: Pass all of the dependencies an object needs through its initialization function.

#### The Class

```
class XYZViewModel {

    private var fetcher: XYZFetching
    private var service: XYZService

    init(fetcher: XYZFetching, service: XYZService) {
        self.fetcher = fetcher
        self.service = service
    }

    func load() -> Data {
        return fetcher.getData(service)
    }

}
```

#### The Factory

```
register { XYZViewModel(fetcher: resolve(), service: resolve()) }
```

## 4. Service Locator<a name=locator></a>

#### Definition

Finally, a Service Locator is basically a service that locates the resources and dependencies an object needs.

#### The Class

```
class MyViewController: UIViewController {
    lazy var viewModel: XYZViewModel = Ressolver.resolve()
}
```

#### The Factory

Since the class is reaching out to the Service Locator directly (Resolver), no registration factory is needed.
