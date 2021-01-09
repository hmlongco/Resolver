#  Resolver: Protocols

### Registering a protocol

Remember, Resolver automatically infers the registration type based on the type of object returned by the factory closure.

As such, registering a protocol that's implemented by a specific type of an object is pretty straightforward.

```swift
main.register { XYZCombinedService() as XYZFetching }
```

Here, we're registering how to get an object that implements the XYZFetching protocol.

The registration factory is *creating* an object of type `XYZCombinedService`, but it's *returning* a type of `XYZFetching`, and that's what's being registered.

### Registering an object with multiple protocols

Registering an object with multiple protocols is pretty much the same as the above, except you need to register each protocol separately.

```swift
main.register { XYZCombinedService() as XYZFetching }
main.register { XYZCombinedService() as XYZUpdating }
```

One should note in this example that the factories for XYZFetching and XYZUpdating are each instantiating and returning their own separate, distinct instances of `XYZCombinedService`, even though both interfaces were actually implemented in the same object.

Sometimes this is what you want.

But it's more likely that if both interfaces were implemented in the same object, you'd like to resolve both interfaces to the same object during a given resolution cycle.

### Protocols sharing the same instance

Consider the next example:

```swift
main.register { resolve() as XYZCombinedService as XYZFetching }
main.register { resolve() as XYZCombinedService as XYZUpdating }
main.register { XYZCombinedService() }
```

It looks strange, but it makes sense. In the first line you're asking Resolver to resolve a XYZCombinedService instance, which you're registering and returning as type XYZFetching.

In the second line you're asking Resolver to again resolve a XYZCombinedService instance, which you're registering and returning as type XYZUpdating.

The last line registers how to make an XYZCombinedService().

Now, both the XYZFetching and XYZUpdating protocols are tied to the same object, and given the default [graph scope](Scopes.md), only one instance of XYZCombinedService will be constructed during a specific [resolution cycle](Cycle.md) when both protocols are resovled.

### Protocols sharing the same instance across resolution cycles

The preceding example shares `XYZCombinedService` during a given [resolution cycle](Cycle.md).

But what if we want any instance of `XYZFetching` or `XYZUpdating` to *always* share the same instance?

```swift
main.register { XYZCombinedService() }
    .scope(.shared)
```

We use a [shared scope](Scopes.md).

### Registering multiple protocols using .implements

A simpler way to rewrite the above registration example uses Resolver's `implements` registration option:

```swift
main.register { XYZCombinedService() }
    .implements(XYZFetching.self)
    .implements(XYZUpdating.self)
```

Resolver registers `XYZCombinedService` for you, and then does the same for `XYZFetching` and `XYZUpdating`, pointing all three registrations to the same factory.

Note that the `.self` passed to the `.implements` method simply tells Swift that we want the object type, not the object itself.
