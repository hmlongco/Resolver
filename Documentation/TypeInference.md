# Resolver: Type Inference

## Registration

Resolver uses Swift type-inference to automatically detect the type of the class or struct being registered, based on the type of object returned by the factory function.

```
main.register { ABCService() }
```

The above factory closure is returning an ABCService, so here we're registering how to create an instance of ABCService.

## Parameters

Resolver can also automatically infer the instance type for method parameters, as shown here.

```
main.register { XYZViewModel(fetcher: resolve(), updater: resolve(), service: resolve()) }
```

In order to be initialized, XYZViewModel needs a fetcher of type XYZFetching, an updater of type XYZUpdating, and a service of type XYZService.

Instead of creating those objects directly, the factory method passes the buck back to Resolver, asking it to "resolve" those parameters as well.

The same chain of events occurs for every object requested during a give resolution cycle, until every dependent object has the resources it needs to be properly initialized.

## Resolution

Resolver can automatically infer the instance type of the object being requested (resolved).

```
var abc: ABCService = Resolver.resolve()!
```

Here the variable type is ABCService, so Resolver will lookup the registration for that type and call its factory closure to resolve it to a specific instance.

## Protocols

### Registering a protocol

Remember, Resolver automatically infers the registration type based on the type of object returned by the factory closure.

As such, registering a protocol that's implemented by a specific type of an object is pretty straightforward.

```
main.register { XYZCombinedService() as XYZFetching }
```

Here, we're registering how to get an object that implements the XYZFetching protocol.

### Registering an object with multiple protocols

```
main.register { XYZCombinedService() as XYZFetching }
main.register { XYZCombinedService() as XYZUpdating }
```

One should note in the above example code that the factories for XYZFetching and XYZUpdating each instantiate and return their own objects, even though both interfaces were actually implemented in the same object.

Sometimes this is what you want.

But it's more likely that if both interfaces were implemented in the same object, you'd like to resolve both interfaces to the same object during a given resolution cycle.

Here's one way to do it.

```
main.register { resolve() as XYZCombinedService as XYZFetching }
main.register { resolve() as XYZCombinedService as XYZUpdating }
main.register { XYZCombinedService() }
```

It looks strange, but it makes sense. In the first line you're asking Resolver to resolve XYZCombinedService, which you're registering and returning as type XYZFetching.

In the second line you're asking Resolver to resolve XYZCombinedService, which you're registering and returning as type XYZUpdating.

The last line registers how to make an XYZCombinedService().

Now, both the XYZFetching and XYZUpdating protocols are tied to the same object, and given the default scope, only one instance of XYZCombinedService will be constructed during a specific resolution cycle.

Finally, a simpler way to rewrite the above registration example uses Resolver's `implements` registration option:

```
main.register { XYZCombinedService() }
.implements(XYZFetching.self)
.implements(XYZUpdating.self)
```

## Explicit Type Specification

You can also explicity tell Resolver the type of object or protocol you want to register or resolve.

```
Resolver.register(ABCServicing.self) { ABCService() }
var abc = Resolver.resolve(ABCServicing.self)!
```


