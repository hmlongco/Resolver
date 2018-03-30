
# Resolver ![icon](https://user-images.githubusercontent.com/709283/32858974-cce8282a-ca12-11e7-944b-c8046156290b.png)

 An ultralight Dependency Injection / Service Locator framework for Swift 4 and iOS.

## Introduction

Dependency Injection frameworks support the [Inversion of Control](https://en.wikipedia.org/wiki/Inversion_of_control) design pattern. Technical definitions aside, dependency injection pretty much boils down to:

| **Giving an object the things it needs to do its job.**

That's it. Dependency injection allows us to write code that's loosely coupled, and as such, easier to reuse, to mock, and  to test.

For more, see: [A Gentle Introduction to Dependency Injection.](https://github.com/hmlongco/Resolver/blob/master/Documentation/Introduction.md)

## Dependency Injection Strategies

There are four classic dependency injection strategies:

1. [Interface Injection](https://github.com/hmlongco/Resolver/blob/master/Documentation/Injection.md#interface)
2. [Property Injection](https://github.com/hmlongco/Resolver/blob/master/Documentation/Injection.md#property)
3. [Constructor Injection](https://github.com/hmlongco/Resolver/blob/master/Documentation/Injection.md#constructor)
4. [Service Locator](https://github.com/hmlongco/Resolver/blob/master/Documentation/Injection.md#locator)

Resolver supports them all. Follow the links for a brief description, examples, and the pros and cons of each.

## Features

Resolver is implemented in just over 300 lines of actual code, but it packs a ton of features into those 300 lines.

* [Automatic Type Inference](https://github.com/hmlongco/Resolver/blob/master/Documentation/Types.md)
* [Scopes: Application, Cached, Graph, Shared, and Unique](https://github.com/hmlongco/Resolver/blob/master/Documentation/Scopes.md)
* [Protocols](https://github.com/hmlongco/Resolver/blob/master/Documentation/Protocols.md)
* [Optionals](https://github.com/hmlongco/Resolver/blob/master/Documentation/Optionals.md)
* [Named Instances](https://github.com/hmlongco/Resolver/blob/master/Documentation/Names.md)
* [Argument Passing](https://github.com/hmlongco/Resolver/blob/master/Documentation/Arguments.md)
* [Custom Containers & Nested Containers](https://github.com/hmlongco/Resolver/blob/master/Documentation/Scopes.md)
* [Storyboard Support](https://github.com/hmlongco/Resolver/blob/master/Documentation/Storyboards.md)

TLDR: If nothing else, make sure you read about [Automatic Type Inference](https://github.com/hmlongco/Resolver/blob/master/Documentation/Types.md) and [Scopes](https://github.com/hmlongco/Resolver/blob/master/Documentation/Scopes.md).

## Using Resolver

Using Resolver is a simple, three-step process:

1. [Add Resolver to your project.](https://github.com/hmlongco/Resolver/blob/master/Documentation/Installation.md)
2. [Register the classes and services your app requires.](https://github.com/hmlongco/Resolver/blob/master/Documentation/Registration.md)
3. [Use Resolver to resolve those instances when needed.](https://github.com/hmlongco/Resolver/blob/master/Documentation/Resolving.md)

## Why Resolver?

As mentioned, Resolver is an ultralight Dependency Injection system, implemented in just over 300 lines of code and contained in a single file.

Further, and unlike some other systems, Resolver is written in 100% Swift 4, with no Objective-C code, method swizzling, or internal dependencies on the Objective-C runtime.

Resolver is also designed for performance. [SwinjectStoryboard](https://github.com/Swinject/SwinjectStoryboard), for example, is a great dependency injection system, but Resolver clocks out to be about 800% faster at resolving dependency chains than Swinject.

Finally, with  [Automatic Type Inference](https://github.com/hmlongco/Resolver/blob/master/Documentation/Types.md) you also tend to write about 40-60% less dependency injection code using Resolver.

## Additional Resouces

* [API Documentation](https://hmlongco.github.io/Resolver/Documentation/API/Classes/Resolver.html)
* [Inversion of Control Design Pattern ~ Wikipedia](https://en.wikipedia.org/wiki/Inversion_of_control)
* [Inversion of Control Containers and the Dependency Injection pattern ~ Martin Fowler](https://martinfowler.com/articles/injection.html)
* [Nuts and Bolts of Dependency Injection in Swift](https://cocoacasts.com/nuts-and-bolts-of-dependency-injection-in-swift/)
* [SwinjectStoryboard](https://github.com/Swinject/SwinjectStoryboard)
