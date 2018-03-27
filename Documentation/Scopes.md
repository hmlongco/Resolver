#  Resolver: Scopes

## What's a scope, and why do I want one?

Scopes are used to control the lifecycle of a given object instance.

Resolver has five built-in scopes: Application, Cached, Graph, Shared, and Unique.

All scopes, with the exception of `unique`, are basically caches, and those caches are used to keep track of the objects they create.

How long? Well, that depends on the scope.

## Scope: Graph

This scope will reuse any instances resolved during a given resolution cycle.

When all objects are resolved the cached instances will be discarded and the next call to resolve them will produce new instances.

Graph is Resolver's **default** scope, so check out the following code:

```
main.register { XYZViewModel(fetcher: resolve(), updater: resolve(), service: resolve()) }
main.register { resolve() as XYZCombinedService as XYZFetching }
main.register { resolve() as XYZCombinedService as XYZUpdating }
main.register { XYZCombinedService() }

var viewModel: XYZViewModel = resolver.resolve()!
```

When the call to `resolve` is made, Resolver needs to create an instance of `XYZViewModel`, so it locates and calls the proper factory. That factory is happy to comply, but in order to make a XYZViewModel it's first going to need to resolve all of that object's initialization parameters.

This starts with `fetcher`, which ultimately resolves to `XYZCombinedService`, so the `XYZCombinedService` factory is called to create one. This instance is returned and it's *also* cached in the current object graph.

The next parameter is an `updater`, which coincidentally for this example *also* resolves to `XYZCombinedService`.

But since we've already resolved `XYZCombinedService` once during this cycle, the cached instance will be returned as the parameter for `updater`.

Resolver then resolves the `service` object, and the code initializes a copy of `XYZViewModel` and returns it.

The graph tracks all objects resolved by all objects that are resolved by all objects... until the final result is returned.

If you don't want this behavior, and if every request should get its own `unique` copy, specify it using the `unique` scope.

## Scope: Unique

This is the simplist scope, in that Resolver calls the registration factory to create a new instance of your type each and every time you call resolve.

It's specified like this:

```
main.register { XYZCombinedService() }
    .scope(unique)
```

## Scope: Application

The `application` scope will make Resolver retain a given instance once resolved the first time, and any subsequent resolutions will always return the inital instance.

```
main.register { XYZApplicationService() }
    .scope(application)
```

This is basically a `Singleton`.

## Scope: Shared

This scope stores a *weak* reference to the resolved instance.

```
main.register { MyViewModel() }
    .scope(shared)
```

While a strong reference to the resolved instance exists any subsequent calls to resolve will return the same instance.

However, once all strong references are released, the shared instance is released, and the next call to resolve will produce a new instance.

This is useful in cases like Master/Detail view controllers, where it's possible that both the MasterViewController and the DetailViewController would like to "share" the same instance of a specific view model.

## Scope: Cached

This scope stores a strong reference to the resolved instance. Once created, every subsequent call to resolve will return the same instance.

```
main.register { MyViewModel() }
    .scope(cached)
```

This is similar to how an application scope behaves, but unlike an application scope, cached scopes can be `reset`, releasing their cached objects.

This is useful if you need, say, a session-level scope that caches specific information until a user logs out.

```
Resolver.cached.reset()
```

## Custom Scopes

You can add and use your own scopes. Usually, and as mentioned above, you might want your own session-level scope to cache information that's needed for as long as a given user is logged in.

To create your own session cache, add the following to your code:

```
extension Resolver {
static let session = ResolverScopeCache()
}
```
It can then be used and specified like any built-in scope.

```
main.register { UserManager() }
    .scope(session)
```


