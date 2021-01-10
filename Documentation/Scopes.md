#  Resolver: Scopes

## What's a scope, and why do I want one?

Scopes are used to control the lifecycle of a given object instance once it's been resolved. That means that scopes are basically caches, and those caches are used to keep track of the objects they create.

When asked to resolve a particular service, Resolver will find the registration for that service and ask its associated *scope* to provide the instance needed. If the object exists in the cache for that scope then a reference to the cached object is returned. If it *doesn't* exist in the cache, then Resolver will make one using the registration factory and then add it to the cache so it's available next time.

This means that *every* service requested from a scope, with the sole exception of `unique`,  will be cached for some period of time.

How long? Well, that depends on the scope. Some cached instances exist only during a given [resolution cycle](Cycle.md), while others my stick around and maintain a single instance for the entire lifetime of the app.

Resolver has five built-in scopes, all defined on the type `ResolverScope`:

* [.application](#application)
* [.cached](#cached)
* [.graph](#graph) (default)
* [.shared](#shared)
* [.unique](#unique)

Make sure you know and understand the differences between them, becaue if there's one advanced feature of Resolver you absolutely *must* understand, it's this one.

## How do I assign a Scope?

Registrations are assigned to a given scope using the `.scope(...)` modifier on a given registration.  

```swift
register { XYZApplicationService() }
    .scope(.application)
```

If you don't specify a scope for a given registration Resolver will punt and use the globally defined [default scope](#default) (usually [.graph](#graph)). This means that all registrations exist in a given scope, explicitly specified or not. 


## Scope: Application<a name=application></a>

The `application` scope will make Resolver retain a given object instance once it's been resolved the first time, and any subsequent resolutions will *always* return the initial instance.

```swift
register { XYZApplicationService() }
    .scope(.application)
```

This effectively makes the object a `Singleton`.

## Scope: Cached<a name=cached></a>

This scope stores a strong reference to the resolved instance. Once created, every subsequent call to resolve will return the same instance.

```swift
register { MyViewModel() }
    .scope(.cached)
```

This is similar to how an application scope behaves, but unlike an application scope, cached scopes can be `reset`, releasing their cached objects.

This is useful if you need, say, a session-level scope that caches specific information until a user logs out.

```swift
ResolverScope.cached.reset()
```

You can also add your own [custom caches](#custom) to Resolver.

## Scope: Graph<a name=graph></a>

This scope will reuse any object instances resolved during a given [resolution cycle](Cycle.md).

Once the requested object is resolved any internally cached instances will be discarded and the next call to resolve them will produce new instances.

Graph is Resolver's **default** scope, so check out the following code:

```swift
register { XYZViewModel(fetcher: resolve(), updater: resolve(), service: resolve()) }
register { resolve() as XYZCombinedService as XYZFetching }
register { resolve() as XYZCombinedService as XYZUpdating }
register { XYZCombinedService() }

var viewModel: XYZViewModel = resolver.resolve()
```

When the call to `resolve` is made, Resolver needs to create an instance of `XYZViewModel`, so it locates and calls the proper factory. That factory is happy to comply, but in order to make a XYZViewModel it's first going to need to resolve all of that object's initialization parameters.

This starts with `fetcher`, which ultimately resolves to `XYZCombinedService`, so the `XYZCombinedService` factory is called to create one. This instance is returned and it's *also* cached in the current object graph.

The next parameter is an `updater`, which coincidentally for this example *also* resolves to `XYZCombinedService`.

But since we've already resolved `XYZCombinedService` once during this cycle, the cached instance will be returned as the parameter for `updater`.

Resolver then resolves the `service` object, and the code initializes a copy of `XYZViewModel` and returns it.

The graph tracks all of the objects that are resolved by all of the objects that are resolved by all of the objects... until the final result is returned. At which point all of the internally cached references are released and your application now is responsible for the object's lifecycle.

If you don't want this behavior, and if every request should get its own `unique` copy, specify it using the `unique` scope.

## Scope: Shared<a name=shared></a>

This scope stores a *weak* reference to the resolved instance.

```
register { MyViewModel() }
    .scope(.shared)
```

While a strong reference to the resolved instance exists any subsequent calls to resolve will return the same instance.

However, once all strong references are released, the shared instance is released, and the next call to resolve will produce a new instance.

This is useful in cases like Master/Detail view controllers, where it's possible that both the MasterViewController and the DetailViewController would like to "share" the same instance of a specific view model.

**Note that value types, including structs, are never shared since the concept of a weak reference to them doesn't apply.**

Only class types can have weak references, and as such only class types can be shared.

## Scope: Unique<a name=unique></a>

This is the simplest scope, in that Resolver calls the registration factory to create a new instance of your type each and every time you call resolve.

It's specified like this:

```swift
register { XYZCombinedService() }
    .scope(.unique)
```

## The Default Scope<a name=default></a>

The default scope used by Resolver when registering an object is [graph](#graph).

But you can change that if you wish, with the only caveat being that you need to do so **before** you do your first registration.

As such, changing the default scope behavior to `unique` would best be done as follows:

```swift
extension Resolver: ResolverRegistering {
    static func registerAllServices() {
        Resolver.defaultScope = .unique
        registerMyNetworkServices()
    }
}
```

## Custom Caches<a name=custom></a>

You can add and use your own scopes. As mentioned above, you might want your own session-level scope to cache information that's needed for as long as a given user is logged in.

To create your own distinct session cache, add the following to your main `AppDelegate+Injection.swift` file:

```swift
extension ResolverScope {
    static let session = ResolverScopeCache()
}
```

Your session scope can then be used and specified just like any built-in scope.

```swift
register { UserManager() }
    .scope(.session)
```

And it can be reset as needed.

```swift
ResolverScope.session.reset()
```

## The ResolverScope Protocol

Finally, if you need some behavior not supported by the built in scopes, you can roll your own using the `ResolverScopeType` protocol and add it to Resolver as shown in [Custom Caches](#custom).

Just use the existing implementations as your guides.
