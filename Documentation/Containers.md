#  Resolver: Containers

## What are containers?

In a Dependency Injection system, a container *contains* alll of the service registrations. When a service is being *resolved*, the container is searched to find the correct registration and corresponding factory.

In Resolver, a resolver instance contains its registration code, its resolution code, and a corresponding container. Put another way, each and every instance of a Resolver *is* a container.

## Resolver's Main Container

Inspect Resolver's code and you'll see the following.

```
public final class Resolver {
    public static let main: Resolver = Resolver()
    public static var root: Resolver = main
}
```

Resolver creates a *main* container that it uses as its default container for all static registrations. It also defines a *root* contrainer that defaults to pointing to the *main* container.

## Static Registration Functions

This basically means that when you do....

```
extension Resolver: ResolverRegistering {
    static func registerAllServices() {
        register { XYZNetworkService(session: resolve()) }
        register { XYZSessionService() }
    }
}
```

You're effectively doing...

```
extension Resolver: ResolverRegistering {
    static func registerAllServices() {
        main.register { XYZNetworkService(session: root.resolve()) }
        main.register { XYZSessionService() }
    }
}
```

The static register and resolve functions simply pass the buck to main and root, respectively.

```
public static func resolve<Service>(_ type: Service.Type = Service.self, name: String? = nil, args: Any? = nil) -> Service {
    return root.resolve(type, name: name, args: args)
}
```

## Creating your own containers

Creating your own container is simple, and similar to creating your own scope caches.

```
extension Resolver {
    static let mock = Resolver()
}
```

It could then be used as follows.

```
extension Resolver: ResolverRegistering {
    static func registerAllServices() {
        mock.register { XYZNetworkService(session: mock.resolve()) }
        mock.register { XYZSessionService() }
    }
}

class MyClass {
    var session: XYZNetworkService = Resolver.mock.resolve()
}
```

By itself, however, Resolver's main container can handle thousands of registrations, so the above, while possible, doesn't tend to be particularly useful. On its own, that is.

## Nested Containers

So once again, and just to be perfectly clear, when you do `Resolver.resolve(SomeClass.self)`,  you're effectively doing `Resolver.root.resolve(SomeClass.self)`.

This implies that if root were to point to a different container, like our *mock* container above, that container would then become the default container used for all resolutions. While true, however, that also means that any services registered in *main* are now lost.

Now consider the following:

```
extension Resolver {
    static let mock = Resolver(parent: main)

    static func registerAllServices() {
        register { XYZNetworkService(session: resolve()) }
        register { XYZSessionService() }
        
        #if DEBUG
        mock.register { XYZMockSessionService() as XYZSessionService }
        root = mock
        #end
    }
}
```

Now, when in DEBUG more, *root* is switched out and points to *mock*. When a service is resolved, **mock will now be searched first.**

This means that the `XYZSessionService` service we just defined in *mock* will be used over any matching service defined in *main*.  

If a service is **not** found in *mock*,  the *main* parent container will be searched automatically, thanks to our adding the parent parameter to `mock = Resolver(parent: main)`.

## Party Trick?

One might ask why we simply don't do the following:

```
extension Resolver {
    static func registerAllServices() {
        register { XYZNetworkService(session: resolve()) }
        register { XYZSessionService() }

        #if DEBUG
        mock.register { XYZMockSessionService() as XYZSessionService }
        #end
    }
}
```

Here, if we're in DEBUG mode our later registration of `XYZSessionService` overwrites the earler one and the mocked version is constructed and used instead.

Isn't swapping out the containers just a party trick?

But what if, for example, we want to keep both registrations and use the proper one at the proper time? 

Consider the following:

```
extension Resolver {
    #if DEBUG
    static let mock = Resolver(parent: main)
    #end
    
    static func registerAllServices() {
        register { XYZNetworkService(session: resolve()) }
        register { XYZSessionService() }

        #if DEBUG
        mock.register { XYZMockSessionService() as XYZSessionService }
        #end
    }
}
```

And then somewhere in our code we do this before we enter a given section:

```
#if DEBUG
Resolver.root = Resolver.mock
#end
```

And then when exiting that section:

```
#if DEBUG
Resolver.root = Resolver.main
#end
```

Now the app behaves normally up until we enter that section of our app. It then switches to using the mocked services for all injections past that point.

Returning, we switch back and the app again behaves normally.

Nice party trick, don't you think?

