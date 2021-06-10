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
            XCTAssert(s1.id == s2.id)
        } else {
            XCTFail("sessions not resolved")
        }
    }

    func testResolverScopeShared() {
        resolver.register { XYZSessionService() }
            .scope(.shared)
        var service1: XYZSessionService? = resolver.optional()
        var service2: XYZSessionService? = resolver.optional()
        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
        var originalID: UUID!
        if let s1 = service1, let s2 = service2 {
            XCTAssert(s1.id == s2.id)
            originalID = s1.id
        } else {
            XCTFail("sessions not shared")
        }
        // Release
        service1 = nil
        service2 = nil
        // and try again
        if let newService: XYZSessionService = self.resolver.optional() {
            XCTAssert(originalID != newService.id)
        } else {
            XCTFail("newService not resolved")
        }
     }

    func testResolverScopeApplication() {
        resolver.register { XYZSessionService() }.scope(.application)
        let service1: XYZSessionService? = resolver.optional()
        let service2: XYZSessionService? = resolver.optional()
        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
        if let s1 = service1, let s2 = service2 {
            XCTAssert(s1.id == s2.id)
        } else {
            XCTFail("sessions not cached")
        }
    }

    func testResolverScopeCached() {
        // Reset...
        ResolverScope.cached.reset()
        resolver.register { XYZSessionService() }.scope(.cached)
        let service1: XYZSessionService? = resolver.optional()
        let service2: XYZSessionService? = resolver.optional()
        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
        var originalID: UUID!
        if let s1 = service1, let s2 = service2 {
            XCTAssert(s1.id == s2.id)
            originalID = s1.id
        } else {
            XCTFail("sessions not cached")
        }
        // Reset...
        ResolverScope.cached.reset()
        // ...and try again
        if let newService: XYZSessionService = resolver.optional() {
            XCTAssert(originalID != newService.id)
        } else {
            XCTFail("newService not resolved")
        }
    }

    func testResolverScopeCachedImplements() {
        // Reset...
        ResolverScope.cached.reset()
        resolver.register { XYZSessionService() }
            .implements(XYZSessionProtocol.self)
            .scope(.cached)
        let service1: XYZSessionService? = resolver.optional()
        let service2: XYZSessionService? = resolver.optional()
        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
        // Also test if "implements" protocol resolves
        let service3: XYZSessionProtocol? = resolver.optional()
        XCTAssertNotNil(service3)
        // check identity
        var originalID: UUID?
        if let s1 = service1, let s2 = service2, let s3 = service3 {
            XCTAssert(s1.id == s2.id)
            XCTAssert(s2.id == s3.id)
            originalID = s1.id
        } else {
            XCTFail("sessions not cached")
        }
        // Reset...
        ResolverScope.cached.reset()
        // ...and try again
        var newUUID: UUID?
        if let newService: XYZSessionService = resolver.optional(), let originalID = originalID {
            XCTAssert(originalID != newService.id)
            newUUID = newService.id
        } else {
            XCTFail("newService not resolved")
        }
        // Reset...
        ResolverScope.cached.reset()
        // ...and try once more with protocol
        if let newService: XYZSessionProtocol = resolver.optional(), let originalID = originalID, let newID = newUUID {
            XCTAssert(originalID != newService.id)
            XCTAssert(newID != newService.id)
        } else {
            XCTFail("newService not resolved")
        }
    }

    func testResolverScopeUnique() {
        resolver.register { XYZSessionService() }.scope(.unique)
        let service1: XYZSessionService? = resolver.optional()
        let service2: XYZSessionService? = resolver.optional()
        XCTAssertNotNil(service1)
        XCTAssertNotNil(service2)
        if let s1 = service1, let s2 = service2 {
            XCTAssert(s1.id != s2.id)
        } else {
            XCTFail("sessions not resolved")
        }
    }


}
