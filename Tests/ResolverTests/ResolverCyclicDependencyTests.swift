//
//  ResolverCyclicDependencyTests.swift
//  ResolverTests
//
//  Created by Michael Long on 12/1/20.
//

import XCTest
@testable import Resolver

private var resolver: Resolver!

class ResolverCyclicDependencyTests: XCTestCase {

    override func setUp() {
        super.setUp()

        resolver = Resolver()
        
        resolver.register(name: "graph") {
            CyclicA(resolver.resolve())
        }
        .resolveProperties { (r, a) in
            r.resolve(CyclicC.self).a = a
        }

        resolver.register(name: "properties") {
            CyclicA(resolver.resolve())
        }
        .resolveProperties { (r, a) in
            a.b.c.a = a
        }

        resolver.register {
            CyclicB(resolver.resolve())
        }

        resolver.register {
            CyclicC()
        }

        resolver.register {
            InjectedCyclicA()
        }
        .scope(Resolver.shared)

        resolver.register {
            InjectedCyclicB()
        }

        resolver.register {
            InjectedCyclicC()
        }
    }

    override func tearDown() {
        super.tearDown()
    }

    func testCyclicDependencyRegistrationViaProperties() {
        let a: CyclicA = resolver.resolve(name: "properties")
        XCTAssertNotNil(a)
        XCTAssertNotNil(a.b)
        XCTAssertNotNil(a.b.c)
        XCTAssertNotNil(a.b.c.a)
        XCTAssert(ObjectIdentifier(a) == ObjectIdentifier(a.b.c.a!))
    }

    func testCyclicDependencyRegistrationViaGraph() {
        let a: CyclicA = resolver.resolve(name: "graph")
        XCTAssertNotNil(a)
        XCTAssertNotNil(a.b)
        XCTAssertNotNil(a.b.c)
        XCTAssertNotNil(a.b.c.a)
        XCTAssert(ObjectIdentifier(a) == ObjectIdentifier(a.b.c.a!))
    }

    func testInjectedCyclicDependencyRegistration() {
        let a: InjectedCyclicA = resolver.resolve()
        XCTAssertNotNil(a)
        XCTAssertNotNil(a.b)
        XCTAssertNotNil(a.b.c)
        XCTAssertNotNil(a.b.c.a)
        XCTAssert(ObjectIdentifier(a) == ObjectIdentifier(a.b.c.a!))
    }

}

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


class InjectedCyclicA {
    @Injected(container: resolver) var b: InjectedCyclicB
}

class InjectedCyclicB {
    @Injected(container: resolver) var c: InjectedCyclicC
}

class InjectedCyclicC {
    @WeakLazyInjected(container: resolver) var a: InjectedCyclicA?
}
