# Resolver: Type Inference

## Registration

Resolver uses Swift type-inference to automatically detect the type of the class or struct being registered, based on the type of object returned by the factory function.

```swift
main.register { ABCService() }
```

The above factory closure is returning an ABCService, so here we're registering how to create an instance of ABCService.

## Parameters

Resolver can also automatically infer the instance type for method parameters, as shown here.

```swift
main.register { XYZViewModel(fetcher: resolve(), updater: resolve(), service: resolve()) }
```

In order to be initialized, XYZViewModel needs a fetcher of type XYZFetching, an updater of type XYZUpdating, and a service of type XYZService.

Instead of creating those objects directly, the factory method passes the buck back to Resolver, asking it to "resolve" those parameters as well.

The same chain of events occurs for every object requested during a given resolution cycle, until every dependent object has the resources it needs to be properly initialized.

## Resolution

Resolver can automatically infer the instance type of the object being requested (resolved).

```swift
var abc: ABCService = Resolver.resolve()
```

Here the variable type is ABCService, so Resolver will lookup the registration for that type and call its factory closure to resolve it to a specific instance.

## Explicit Type Specification

You can also explicitly tell Resolver the type of object or protocol you want to register or resolve.

```
Resolver.register(ABCServicing.self) { ABCService() }
var abc = Resolver.resolve(ABCServicing.self)
```
