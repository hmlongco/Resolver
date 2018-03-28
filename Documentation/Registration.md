#  Resolver: Registration

## Add the AppDelegate

Add a file named `AppDelegate+Injection.swift` to your project and add the following code:

```
extension Resolver: ResolverRegistering {
    static func registerAllServices() {

    }
}
```

That's it. You've added the basic level of intergration.

But as is, it's not very useful until you actually register some classes.

## Add Injection Files<a name=files></a>

It's a common practice with Resolver, Swinject, and other DI systems to add addtional "injection" files to your project to support the dependencies needed by a particular part of the code base.

Let's say you have a group in your project folder named "NetworkServices", and you want to register some of those services for use by Resolver.

#### 1. Add your own registration file.

Go to the NetworkServices folder and add a swift file named: `NetworkServices+Injection.swift`, then add the following to that file...

```
extension Resolver {
    static func registerMyNetworkServices() {

    }
}
```

#### 2. Update the master file.

Now, go back to your  `AppDelegate+Injection.swift` file and add a reference to `registerMyNetworkServices`.

```
extension Resolver: ResolverRegistering {
    static func registerAllServices() {
        registerMyNetworkServices()
    }
}
```

Resolver will automatically call `registerAllServices`, and that function in turn calls each of your own registration functions.

#### 3. Add your own registrations.

Now, housekeeping completed, return to  `NetworkServices+Injection.swift` and add your own registrations.

Just as an example:

```
extension Resolver {

    static func registerMyNetworkServices() {

        // Register protocols XYZFetching and XYZUpdating and create implementation object
        register { XYZCombinedService() }
            .implements(XYZFetching.self)
            .implements(XYZUpdating.self)

        // Register XYZNetworkService and return instance in factory closure
        register { XYZNetworkService(session: resolve()) }

        // Register XYZSessionService and return instance in factory closure
        register { XYZSessionService() }
    }
    
}
```

That's it. Resolver uses  Swift [type inference](Types.md) to automatically determine and register the type of object being returned by the registration factory.

And in the case of `XYZNetworkService`, Resolver is used to infer the type of the session parameter that's needed to initialize a `XYZNetworkService`.

This works with classes, structs, and protocols, though there are a few special cases and considerations for [protocols](Protocols.md).

You can also register [value types](Names.md), though that too has a few special considerations.

