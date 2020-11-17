# Resolver: Optionals

## Why the expected result is not the expected result

Resolver is pretty good at inferring type, but one thing that can trip it up is optionals.

Consider the following:

```swift
Resolver.register() { ABCService() }
var abc: ABCService? = Resolver.resolve()
```

Try the above, and the expected resolution will fail. Why? Well, remember that Resolver depends on Swift to infer the correct type, based on the type of the expected result.

Here, you'd expect the type to be `ABCService`, but to Swift, the type is actually `Optional(ABCService)`.

And though that's the type Resolver will attempt to resolve, it's not the type that was registered beforehand.

## A little help from a friend

Fortunately, the solution is simple.

```swift
var abc: ABCService? = Resolver.optional()
```

The `optional()` method has a different type signature, and using it allows Swift and Resolver to again infer the correct type.

## The other optional

```swift
var abc: ABCService! = Resolver.resolve()
```

This will also fail to resolve, and for the same reason. To Swift, `ABCService` is not an `ABCService`, but an `ImplicitlyUnwrappedOptional(ABCService)`.

Fortunately, the solution is the same.

```swift
var abc: ABCService! = Resolver.optional()
```

## Explicit Type Specification

You can also punt and explicitly tell Resolver the type of object or protocol you want to resolve.

```swift
var abc: ABCService? = Resolver.resolve(ABCService.self)
```

This could be helpful if for some reason you wanted to resolve to a specific instance.

```swift
var abc: ABCServicing? = Resolver.resolve(ABCService.self)
```

## Optional annotation

An annotation is available that supports optional resolving. If the service is not registered, then the value will be nil, otherwise it will be not nil:

```swift
class InjectedViewController: UIViewController {
    @OptionalInjected var service: XYZService?
    func load() {
        service?.load()
    }
}
```
