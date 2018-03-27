
# Resolver ![icon](https://user-images.githubusercontent.com/709283/32858974-cce8282a-ca12-11e7-944b-c8046156290b.png)

 An ultralight Dependency Injection / Service Locator framework for Swift 4 and iOS.

## Introduction

Resolver is Dependency Injection framework for Swift that supports the Inversion of Control design pattern.

Computer Science definitions aside, Dependency Injection pretty much boils down to:

| **Giving an object the things it needs to do its job.**

Dependency Injection allows us to write code that's loosely coupled, and as such, easier to reuse, to mock, and  to test.

For more, read: [A Gentle Introduction to Dependency Injection](https://hmlongco.github.io/Resolver/Documentation/Introduction.md)

## Features

Resolver is just over 300 lines of actual code, but it packs a ton of features into those 300 lines.

* Dependency Registration & Resolution
* [Automatic Type Inference](https://hmlongco.github.io/Resolver/Documentation/TypeInference.md)
* [Protocols](https://hmlongco.github.io/Resolver/Documentation/TypeInference.md#Protocols)
* [Optionals](https://hmlongco.github.io/Resolver/Documentation/Optionals.md)
* Named Instances
* Scopes: Application, Cached, Custom, Graph, Shared, and Unique
* Custom Containers & Nested Containers
* Parameter Passing
* Storyboard Support
* Thread Safe

## Installation

The plan is for Resolver to be Carthage, Cocoapods, and Swift Framework compliant.

That's the plan. For now, however, just checkout the project and add `Resolver.swift` to your project's Third Party Software folder.

Add `ResolverStoryboard.swift` for optional Storyboard support.

## Why Resolver?

As mentioned, Resolver is an ultralight Dependency Injection / Service Locator framework, weighing in at just over 300 lines of actual code.

Resolver is also highly performant. SwinjectStoryboard, for example, is a great DI system, but Resolver clocks out to be about 800% faster than Swinject.

You also write about 60% less code using Resolver.

## Additional Resouces

* [API Documentation](https://hmlongco.github.io/Resolver/Documentation/API/Classes/Resolver.html)
