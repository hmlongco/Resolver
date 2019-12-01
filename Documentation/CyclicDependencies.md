# Resolver: Cyclic Dependencies

There are times when our objects have cyclic depenencies. Object A depends on object B, which in turn needs a reference back to object A. 

```
class ClassA {
    var b: ClassB
}

class ClassB {
    weak var a: ClassA?
}
```
Note that B's reference back to A is weak so we don't create reference cycles in ARC.

How do we solve this injection problem in Resolver?

## The Code

Let's start by defining our classes as follows:

```
class ClassA {
    var b: ClassB
    init(b: ClassB) {
        self.b = b
    }
}

class ClassB {
    weak var a: ClassA?
}
```
We already know how to make an A that contains a B.
```
register { ClassA(b: resolve()) }
register { ClassB() }
```
Now all we need to do to resolve the cyclic dependency in registration is use Resolver's `resolveProperties` modifier on ClassA.
```
register { ClassA(b: resolve()) }
    .resolveProperties { (_, a) in
        a.b.a = a
    }
register { ClassB() }
```
A is resolved, then B is resolved, then we simply tell B about A.

## Using Injected
One can also do this with the current version of Resolver and its new property wrapper.
```
class ClassP {
    @Injected var c: ClassC
}

class ClassC {
    weak var p: ClassP?
}
```
With a registration scheme almost identical to the first case...
```
register { ClassA() }
    .resolveProperties { (_, a) in
        a.b.a = a
    }
register { ClassB() }
```
Once more the parent class has a reference to its child, and the child obtains a weak reference back to its shared parent.

## Lazy Injection
One might be tempted to do this using using @LazyInjected on the child class, as the "lazy" aspect on C gives P a chance to fully initialize. We then obtain a reference to the shared parent object when the lazy injection resolution cycle occurs during the first reference to p on the child class.
```
class ClassP {
    @Injected var c: ClassC
}

class ClassC {
    @LazyInjected var p: ClassP
}
```
With registration like...
```
register { ClassP() }.scope(shared)
register { ClassC() }
```
The parent class has a reference to its child, and the child obtains a reference back to its shared parent. Bing. Problem solved.

**This may seem straightforward, but we've also created a strong reference cycle between ClassA and ClassB.**

As a general rule, you don't want to do this, but you should note that it's in fact possble to break the cycle by releasing the lazilly instantiated object manually at some point in your code.

```
extension ClassC {
    func release() {
        self.$p.release()
    }
}
```
