//
//  ResolverScopeValueTests.swift
//  ResolverTests
//
//  Created by Michael Long on 3/30/18.
//  Copyright © 2018 com.hmlong. All rights reserved.
//

import XCTest
@testable import Resolver

class ResolverScopeValueTests: XCTestCase {

    var resolver: Resolver!

    override func setUp() {
        super.setUp()
        resolver = Resolver()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testResolverScopeGraph() {
        resolver.register { XYZValue() }
        resolver.register { XYZValueService( self.resolver.optional(), self.resolver.optional() ) }
        let service: XYZValueService? = resolver.optional()
        XCTAssertNotNil(service)
        XCTAssertNotNil(service?.value1)
        XCTAssertNotNil(service?.value2)
        if let s1 = service?.value1, let s2 = service?.value2 {
            XCTAssert(s1.id != s2.id)
        } else {
            XCTFail("values not resolved")
        }
    }

    func testResolverScopeShared() {
        resolver.register { XYZValue() }.scope(Resolver.shared)
        var value1: XYZValue? = resolver.optional()
        var value2: XYZValue? = resolver.optional()
        XCTAssertNotNil(value1)
        XCTAssertNotNil(value2)
        // value types will not be shared since weak references do not apply
        if let s1 = value1, let s2 = value2 {
            XCTAssert(s1.id != s2.id)
        } else {
            XCTFail("values not shared")
        }
        let oldID = value1?.id ?? UUID()
        // Release and try again
        value1 = nil
        value2 = nil
        if let newValue: XYZValue = resolver.optional() {
            XCTAssert(newValue.id != oldID)
        } else {
            XCTFail("newValue not resolved")
        }
    }

    func testResolverScopeApplication() {
        resolver.register { XYZValue() }.scope(Resolver.application)
        let value1: XYZValue? = resolver.optional()
        let value2: XYZValue? = resolver.optional()
        XCTAssertNotNil(value1)
        XCTAssertNotNil(value2)
        if let s1 = value1, let s2 = value2 {
            XCTAssert(s1.id == s2.id)
        } else {
            XCTFail("values not cached")
        }
    }

    func testResolverScopeCached() {
        resolver.register { XYZValue() }.scope(Resolver.cached)
        let value1: XYZValue? = resolver.optional()
        let value2: XYZValue? = resolver.optional()
        XCTAssertNotNil(value1)
        XCTAssertNotNil(value2)
        if let s1 = value1, let s2 = value2 {
            XCTAssert(s1.id == s2.id)
        } else {
            XCTFail("values not cached")
        }
        let oldID = value1?.id ?? UUID()
        // Reset and try again
        Resolver.cached.reset()
        if let newService: XYZValue = resolver.optional() {
            XCTAssert(newService.id != oldID)
        } else {
            XCTFail("newService not resolved")
        }

    }

    func testResolverScopeUnique() {
        resolver.register { XYZValue() }.scope(Resolver.unique)
        let value1: XYZValue? = resolver.optional()
        let value2: XYZValue? = resolver.optional()
        XCTAssertNotNil(value1)
        XCTAssertNotNil(value2)
        if let s1 = value1, let s2 = value2 {
            XCTAssert(s1.id != s2.id)
        } else {
            XCTFail("values not resolved")
        }
    }

}
