
# Resolver ![icon](https://user-images.githubusercontent.com/709283/32858974-cce8282a-ca12-11e7-944b-c8046156290b.png)

 An ultralight Dependency Injection / Service Locator framework for Swift 4 and iOS.

## Introduction

Resolver is a Dependency Injection framework for Swift that supports the Inversion of Control design pattern.

Computer Science definitions aside, Dependency Injection pretty much boils down to:

| **Giving an object the things it needs to do its job.**

Dependency Injection allows us to write code that's loosely coupled, and as such, easier to reuse, to mock, and  to test.

For more, read: [A Gentle Introduction to Dependency Injection](https://github.com/hmlongco/Resolver/blob/master/Documentation/Introduction.md)

## Features

Resolver is just over 300 lines of actual code, but it packs a ton of features into those 300 lines.

* Dependency Registration & Resolution
* [Automatic Type Inference](https://github.com/hmlongco/Resolver/blob/master/Documentation/Types.md)
* [Scopes: Application, Cached, Graph, Shared, and Unique](https://github.com/hmlongco/Resolver/blob/master/Documentation/Scopes.md)
* [Named Instances](https://github.com/hmlongco/Resolver/blob/master/Documentation/Names.md)
* [Special supprt for Protocols](https://github.com/hmlongco/Resolver/blob/master/Documentation/Protocols.md)
* [Special supprt for Optionals](https://github.com/hmlongco/Resolver/blob/master/Documentation/Optionals.md)
* [Custom Containers & Nested Containers](https://github.com/hmlongco/Resolver/blob/master/Documentation/Scopes.md)
* [Parameter Passing](https://github.com/hmlongco/Resolver/blob/master/Documentation/Parameters.md)
* [Storyboard Support](https://github.com/hmlongco/Resolver/blob/master/Documentation/Storyboards.md)
* Thread Safe

## Using Resolver

Using Resolver is a simple, three-step process:

1. [Add Resolver to your project.](https://github.com/hmlongco/Resolver/blob/master/Documentation/Installation.md)
2. [Register the classes and services your app requires.](https://github.com/hmlongco/Resolver/blob/master/Documentation/Registration.md)
3. [Use Resolver to resolve those instances when needed.](https://github.com/hmlongco/Resolver/blob/master/Documentation/Resolving.md)

## Why Resolver?

As mentioned, Resolver is an ultralight Dependency Injection / Service Locator framework, weighing in at just over 300 lines of actual code.

Resolver is written in 100% Swift 4, with no Objective-C code, method swizzling, or dependencies on the Objective-C runtime.

Resolver is also highly performant. SwinjectStoryboard, for example, is a great DI system, but Resolver clocks out to be about 800% faster at resolving dependcy chains than Swinject.

And not to save the best for last, but you also write about 60% less Dependency Injection management code using Resolver.

## Additional Resouces

* [API Documentation](https://hmlongco.github.io/Resolver/Documentation/API/Classes/Resolver.html)
