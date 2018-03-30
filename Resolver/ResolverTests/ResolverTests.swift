//
//  ResolverTests.swift
//  ResolverTests
//
//  Created by Michael Long on 11/14/17.
//  Copyright © 2017 com.hmlong. All rights reserved.
//

import XCTest
@testable import Resolver

class ResolverTests: XCTestCase {

    var resolver: Resolver!

    override func setUp() {
        super.setUp()
        resolver = Resolver()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testRegistrationAndExplicitResolution() {
        resolver.register { XYZSessionService() }
        let session: XYZSessionService? = resolver.resolve(XYZSessionService.self)
        XCTAssert(session != nil)
    }

    func testRegistrationAndInferedResolution() {
        resolver.register { XYZSessionService() }
        let session: XYZSessionService? = resolver.resolve() as XYZSessionService
        XCTAssert(session != nil)
    }

    func testRegistrationAndOptionalResolution() {
        resolver.register { XYZSessionService() }
        let session: XYZSessionService? = resolver.optional()
        XCTAssert(session != nil)
    }

    func testRegistrationAndOptionalResolutionFailure() {
        let session: XYZSessionService? = resolver.optional()
        XCTAssert(session == nil)
    }

    func testRegistrationAndResolutionChain() {
        resolver.register { XYZSessionService() }
        resolver.register { XYZService( self.resolver.optional() ) }
        let service: XYZService? = resolver.optional()
        XCTAssert(service != nil)
        XCTAssert(service?.session != nil)
    }

    func testResolverScopeGraph() {
        resolver.register { XYZSessionService() }
        resolver.register { XYZGraphService( self.resolver.optional(), self.resolver.optional() ) }
        let service: XYZGraphService? = resolver.optional()
        XCTAssert(service != nil)
        XCTAssert(service?.session1 != nil)
        XCTAssert(service?.session2 != nil)
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
        XCTAssert(service1 != nil)
        XCTAssert(service2 != nil)
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

    func testResolverScopeCached() {
        resolver.register { XYZSessionService() }.scope(Resolver.cached)
        let service1: XYZSessionService? = resolver.optional()
        let service2: XYZSessionService? = resolver.optional()
        XCTAssert(service1 != nil)
        XCTAssert(service2 != nil)
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

}
