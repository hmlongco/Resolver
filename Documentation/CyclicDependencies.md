# Resolver: Cyclic Dependencies

There are times when our objects have cyclic depenencies. Object A depends on object B, which depends on object C, which in turn needs a reference back to object A. 

```swift
class CyclicA {
    var b: CyclicB
}

class CyclicB {
    var c: CyclicC
}

class CyclicC {
    var a: CyclicA
}

```

It's a problem. For one thing, you can't create an object A that depends on B that depends on C that depends on A strictly via  object initializers. It's impossible. Class A needs a B be to be constructed, which needs a C, which needs an A... but our orignal A hasn't even been constructed yet becuase it's still waiting on its parameters. In short, we have a classic cyclic dependency.

If you've read about [scopes](Scopes.md), you might think that the default  `graph` scope could be the solution to our problem. But the graph isn't magic, and it suffers from the same fundamental issue: any object in the graph can be reused and referenced... but in order for an object to be in the graph it has to be instantiated... but the objects above can't be instantiated, because they have dependencies...

It's a classic "chicken and the egg" situation.

In general, I try to avoid situations (and architectures) that create circular dependencies. They're problematic and if you're not careful they can easily lead to retain cycles. 

But they do still pop up from time to time, especially in architectures like VIPER. 

So if we can't just ignore the problem, how do we solve it?

## The Code

If you stop and consider the problem, you'll ultimately realize that we're going to need a two pronged approach: 

1. We have to be able to create some chain of objects that *can in fact* be instantiated. 
2. Then, once we have all of the pieces to our puzzle, we can go back and fix up the cyclic dependencies.

Let's start by defining our classes as follows:

```swift
class CyclicA {
    var b: CyclicB
    init(_ b: CyclicB) {
        self.b = b
    }
}

class CyclicB {
    var c: CyclicC
    init(_ c: CyclicC) {
        self.c = c
    }
}

class CyclicC {
    weak var a: CyclicA?
}
```
A needs a B, and B needs a C. C also wants to be able to talk an A, but we'll handle that later. For the moment, however, note that C's reference back to A will be weak and optional so we won't create reference cycles in ARC. This is a classic parent/child relationship in ARC.

Now, we already know how to use Resolver to make an A that contains a B and a B with a C.
```swift
register { CyclicA(resolve()) }
register { CyclicB(resolve()) }
register { CyclicC() }
```
But how do we resolve the cyclic dependency? 

The trick is to use Resolver's `resolveProperties` modifier on CyclicA.
```swift
register { CyclicA(resolve()) }
    .resolveProperties { (r, a) in
        r.resolve(CyclicC.self).a = a
    }
```
This may seem counter-intuitive at first. I want to fix up C, so why isn't the `resolveProperties` modifier on C? 

Think about it. A needs a B, and B needs a C. So when I resolve C my instance for A *doesn't exist yet*. Hence using `resolveProperties` on C would accomplish nothing, since there's nothing in the graph to resolve.

So in the final process we see that A needs a B, and B needs a C... which is resolved and passed to B, B is resolved and passed to A, A is finally instantiated... *and then* we simply tell C about A. Note that C still exists in the dependency graph for this resolution cycle, so it's available to be resolved without specifying any additional scopes.

This could also be accomplished as follows...

```swift
register { CyclicA(resolve()) }
    .resolveProperties { (r, a) in
        a.b.c.a = a
    }
```

Looking at the code, one might in fact question both of these approaches: Should class A be rumaging around in the internals of class C? 

Well, from a traditional software development perspective, the answer is a simple straightforward NO! Separation of concerns and all that.

But when you come right down to it, the **code in class A** isn't doing anything like that. The *dependency system* knows about class C, but then again, that's its job. The *dependency injection code* manages these sorts of dependencies for us so that the  *application code* is unaware of them. 

It doesn't know nor should it care. 

## Using Injected
One can also do this with the current version of Resolver and its new @Injected property wrapper. Here's a typical parent/child relationship.
```swift
class ClassP {
    @Injected var c: ClassC
}

class ClassC {
    weak var p: ClassP?
}
```
With a registration scheme almost identical to the first case...
```swift
register { ClassP() }
    .resolveProperties { (r, p) in
        r.resolve(ClassC.self).p = p
    }
register { ClassC() }
```
Once more the parent class has a reference to its child, and the child obtains a weak reference back to its shared parent.

## Weak Lazy Injection
One might be tempted to solve this using using @LazyInjected on the child class, as the "lazy" aspect on C gives P a chance to fully initialize. We then obtain a reference to the shared parent object when the lazy injection resolution cycle occurs during the first reference to p on the child class.
```swift
class ClassP {
    @Injected var c: ClassC
}

class ClassC {
    @LazyInjected var p: ClassP?
}
```
With registration like...
```swift
register { ClassP() }.scope(shared)
register { ClassC() }
```
The parent class has a reference to its child, and the child obtains a reference back to its shared parent. Bing. Problem solved.

**This may seem straightforward, but we've also created a strong reference cycle between ClassA and ClassB.**

To fix this, use Resolver's latest property wrapper, @WeakLazyInjected.

```swift
class ClassC {
    @WeakLazyInjected var p: ClassP?
}
```
In both cases, note that the registration for `ClassP()` uses `scope(shared)`. This is needed since the lazy injection in class C will occur outside of the graph dependency cycle when `p` is first referenced in the application code.

You can see an actual code sample for these methods in the `ResolverCyclicDependencyTests.swift` unit test.
