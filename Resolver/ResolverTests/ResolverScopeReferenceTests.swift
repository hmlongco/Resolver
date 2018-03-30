//
//  ResolverTests.swift
//  ResolverTests
//
//  Created by Michael Long on 11/14/17.
//  Copyright © 2017 com.hmlong. All rights reserved.
//

import XCTest
@testable import Resolver

class ResolverScopeReferenceTests: XCTestCase {

    var resolver: Resolver!

    override func setUp() {
        super.setUp()
        resolver = Resolver()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testResolverScopeGraph() {
        resolver.register { XYZSessionService() }
        resolver.register { XYZGraphService( self.resolver.optional(), self.resolver.optional() ) }
        let service: XYZGraphService? = resolver.optional()
        XCTAssertNotNil(service)
        XCTAssertNotNil(service?.session1)
        XCTAssertNotNil(service?.session2)
        if let s1 = service?.session1, let s2 = service?.session2 {
            XCTAssert(s1.count == s2.count)
        } else {
            XCTFail("sessions not resolved")
        }
    }

    func testResolverScopeShared() {
        resolver.register { XYZSessionService() }.scope(Resolver.shared)
        var service1: XYZSessionService? = resolver.optional()
        var service2: XYZSessionService? = resolver.optional()
        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
        if let s1 = service1, let s2 = service2 {
            XCTAssert(s1.count == s2.count)
        } else {
            XCTFail("sessions not shared")
        }
        let oldCount = service1?.count ?? 0
        // Release and try again
        service1 = nil
        service2 = nil
        if let newService: XYZSessionService = resolver.optional() {
            XCTAssert(newService.count > oldCount)
        } else {
            XCTFail("newService not resolved")
        }

    }

    func testResolverScopeApplication() {
        resolver.register { XYZSessionService() }.scope(Resolver.application)
        let service1: XYZSessionService? = resolver.optional()
        let service2: XYZSessionService? = resolver.optional()
        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
        if let s1 = service1, let s2 = service2 {
            XCTAssert(s1.count == s2.count)
        } else {
            XCTFail("sessions not cached")
        }
    }

    func testResolverScopeCached() {
        resolver.register { XYZSessionService() }.scope(Resolver.cached)
        let service1: XYZSessionService? = resolver.optional()
        let service2: XYZSessionService? = resolver.optional()
        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
        if let s1 = service1, let s2 = service2 {
            XCTAssert(s1.count == s2.count)
        } else {
            XCTFail("sessions not cached")
        }
        let oldCount = service1?.count ?? 0
        // Reset and try again
        Resolver.cached.reset()
        if let newService: XYZSessionService = resolver.optional() {
            XCTAssert(newService.count > oldCount)
        } else {
            XCTFail("newService not resolved")
        }

    }

    func testResolverScopeUnique() {
        resolver.register { XYZSessionService() }.scope(Resolver.unique)
        let service1: XYZSessionService? = resolver.optional()
        let service2: XYZSessionService? = resolver.optional()
        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
        if let s1 = service1, let s2 = service2 {
            XCTAssert(s1.count != s2.count)
        } else {
            XCTFail("sessions not resolved")
        }
    }


}
