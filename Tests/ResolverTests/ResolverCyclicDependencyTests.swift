//
//  ResolverCyclicDependencyTests.swift
//  ResolverTests
//
//  Created by Michael Long on 12/1/20.
//

import XCTest
@testable import Resolver

class CyclicA {
    var b: CyclicB!
    init(_ b: CyclicB) {
        self.b = b
    }
}

class CyclicB {
    var c: CyclicC!
    init(_ c: CyclicC) {
        self.c = c
    }
}

class CyclicC {
    weak var a: CyclicA?
}

class ResolverCyclicDependencyTests: XCTestCase {

    var resolver: Resolver!

    override func setUp() {
        super.setUp()

        resolver = Resolver()
        
        resolver.register {
            CyclicA(self.resolver.resolve())
        }
        .resolveProperties { (r, a) in
            r.resolve(CyclicC.self).a = a
        }

        resolver.register {
            CyclicB(self.resolver.resolve())
        }

        resolver.register {
            CyclicC()
        }
    }

    override func tearDown() {
        super.tearDown()
    }

    func testStrongCyclicDependencyRegistration() {
        let a: CyclicA = resolver.resolve()
        XCTAssertNotNil(a)
        XCTAssertNotNil(a.b)
        XCTAssertNotNil(a.b.c)
        XCTAssertNotNil(a.b.c)
        XCTAssertNotNil(a.b.c.a)
        XCTAssert(ObjectIdentifier(a) == ObjectIdentifier(a.b.c.a!))
    }

}
