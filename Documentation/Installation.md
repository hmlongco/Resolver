#  Resolver: Installation

## Swift Package Manager

Resolver is available through Swift Package Manager. To install it simply include it in your package dependencies:

```
dependencies: [
    .package(url: "https://github.com/hmlongco/Resolver.git", from: "1.1.2"),
]
```

Or in Xcode via File > Swift Packages > Add Package Dependency...

## CocoaPods

Resolver is available through CocoaPods. To install it, simply add the following line to your Podfile:

```
pod "Resolver"
```

Special thanks to [Khoa Pham](https://github.com/onmyway133) for making the *Resolver* repo available on CocoaPods.

## Carthage

The original plan was for Resolver to be Carthage compliant but now with the introduction of Swift Package Manager for iOS I'm going to skip official Carthage support. 

But all is not lost! If you're using Carthage and want to use Resolver just add it directly in your project as shown below.

## Adding Resolver to your project

Just checkout the project and add `Resolver.swift` to your project's Third Party Software folder. That's it. One file and you're done.

You can also add Resolver to your project as a git submodule.

## Supporting Swift 4

The current version of Resolver supports Swift 5.1. If your project uses an earlier version of Swift then just checkout an earlier version of Resolver (1.0.7).

Or you can follow the instructions below.

## Supporting iOS 9 and iOS 10

The current version of Resolver targets iOS 11 as the minimum supported SDK. 

If you need iOS 10 or earlier then your best option is to add Resolver directly to your project and remove the property wrapper section from the Resolver source code.  

That's basically everything from the `// Swift Property Wrappers` comment to the end of the file.

Doing so should clear the compiler errors you'd otherwise see when archiving your project.
