# Resolver ![icon](https://user-images.githubusercontent.com/709283/32858974-cce8282a-ca12-11e7-944b-c8046156290b.png)

An ultralight Dependency Injection / Service Locator framework for Swift 5.2 on iOS.

## Introduction

Dependency Injection frameworks support the [Inversion of Control](https://en.wikipedia.org/wiki/Inversion_of_control) design pattern. Technical definitions aside, dependency injection pretty much boils down to:

| **Giving an object the things it needs to do its job.**

That's it. Dependency injection allows us to write code that's loosely coupled, and as such, easier to reuse, to mock, and  to test.

For more, see: [A Gentle Introduction to Dependency Injection.](./Documentation/Introduction.md)

## Resolver 1.2 Changes

Note that Resolver 1.2 changed how arguments are passed to the registration factory order to provide better support for passing and handling both single and multiple arguments. 

This is, unfortunately, a breaking change from Resolver 1.1.X, but as the end result is much cleaner code I think it's worth it. If you're *not* using arguments then you should see no issues whatsoever.

See: [Passing and Handling Multiple Arguments](./Documentation/Arguments.md#multiple)

## Dependency Injection Strategies

There are six classic dependency injection strategies:

1. [Interface Injection](./Documentation/Injection.md#interface)
2. [Property Injection](./Documentation/Injection.md#property)
3. [Constructor Injection](./Documentation/Injection.md#constructor)
4. [Method Injection](./Documentation/Injection.md#method)
5. [Service Locator](./Documentation/Injection.md#locator)
6. [Annotation](./Documentation/Injection.md#annotation) (NEW)

Resolver supports them all. Follow the links for a brief description, examples, and the pros and cons of each.

## Property Wrappers

Resolver now supports resolving services using the new property wrapper syntax in Swift 5.1.

```swift
class BasicInjectedViewController: UIViewController {
    @Injected var service: XYZService
    @LazyInjected var service2: XYZLazyService
    @WeakLazyInjected var service3: XYZAnotherLazyService?
}
```
Just add the Injected keyword and your dependencies will be resolved automatically. See the [Annotation](./Documentation/Annotation.md) documentation for more on this and other strategies.

## Features

Resolver is implemented in just over 700 lines of actual code in a single file, but it packs a ton of features into those 700 lines.

* [Automatic Type Inference](./Documentation/Types.md)
* [Scopes: Application, Cached, Graph, Shared, and Unique](./Documentation/Scopes.md)
* [Protocols](./Documentation/Protocols.md)
* [Optionals](./Documentation/Optionals.md)
* [Named Instances](./Documentation/Names.md)
* [Argument Passing](./Documentation/Arguments.md) (Resolver 1.2 now has built in support for multiple arguments!)
* [Custom Containers & Nested Containers](./Documentation/Containers.md)
* [Cyclic Dependency Support](./Documentation/CyclicDependencies.md)
* [Storyboard Support](./Documentation/Storyboards.md)

TLDR: If nothing else, make sure you read about [Automatic Type Inference](./Documentation/Types.md), [Scopes](./Documentation/Scopes.md), and [Optionals](./Documentation/Optionals.md).

## Using Resolver

Using Resolver is a simple, three-step process:

1. [Add Resolver to your project.](./Documentation/Installation.md)
2. [Register the classes and services your app requires.](./Documentation/Registration.md)
3. [Use Resolver to resolve those instances when needed.](./Documentation/Resolving.md)

## Installation

Resolver supports CocoaPods and the Swift Package Manager.
```swift
pod "Resolver"
```
Resolver itself is just a single source file (Resolver.swift), so it's also easy to simply download the file and add it to your project.

Note that the current version of Resolver (1.1) supports Swift 5.1 and that the minimum version of iOS currently supported with this release is iOS 11.

Read the [installation guide](./Documentation/Installation.md) for information on supporting earlier versions.

## Why Resolver?

As mentioned, Resolver is an ultralight Dependency Injection system, implemented in just over 300 lines of code and contained in a single file.

Resolver is also designed for performance. [SwinjectStoryboard](https://github.com/Swinject/SwinjectStoryboard), for example, is a great dependency injection system, but Resolver clocks out to be about 800% faster at resolving dependency chains than Swinject.

And unlike some other systems, Resolver is written in 100% Swift 5, with no Objective-C code, method swizzling, or internal dependencies on the Objective-C runtime.

Further, Resolver:

* Is tested in production code.
* [Is thread safe (assuming your objects are thread safe).](./Documentation/Threads.md)
* Has a complete set of unit tests.
* Is well-documented.

Finally, with  [Automatic Type Inference](./Documentation/Types.md) you also tend to write about 40-60% less dependency injection code using Resolver.

## Author

Resolver was designed, implemented, and documented by [Michael Long](https://www.linkedin.com/in/hmlong/), a Senior Lead iOS engineer at [CRi Solutions](https://www.clientresourcesinc.com/solutions/). CRi is a leader in developing cutting edge iOS, Android, and mobile web applications and solutions for our corporate and financial clients.

* Email: [mlong@clientresourcesinc.com](mailto:mlong@clientresourcesinc.com)
* Twitter: @hmlco

## License

Resolver is available under the MIT license. See the LICENSE file for more info.

## Additional Resouces

* [API Documentation](./Documentation/API/Classes/Resolver.html)
* [Inversion of Control Design Pattern ~ Wikipedia](https://en.wikipedia.org/wiki/Inversion_of_control)
* [Inversion of Control Containers and the Dependency Injection pattern ~ Martin Fowler](https://martinfowler.com/articles/injection.html)
* [Nuts and Bolts of Dependency Injection in Swift](https://cocoacasts.com/nuts-and-bolts-of-dependency-injection-in-swift/)\
* [Dependency Injection in Swift](https://cocoacasts.com/dependency-injection-in-swift)
* [SwinjectStoryboard](https://github.com/Swinject/SwinjectStoryboard)
* [Swift 5.1 Takes Dependency Injection to the Next Level](https://medium.com/better-programming/taking-swift-dependency-injection-to-the-next-level-b71114c6a9c6)
