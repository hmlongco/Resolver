//
//  ResolverTests.swift
//  ResolverTests
//
//  Created by Michael Long on 11/14/17.
//  Copyright © 2017 com.hmlong. All rights reserved.
//

import XCTest
@testable import Resolver

class ResolverBasicTests: XCTestCase {

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
        XCTAssertNotNil(session)
    }

    func testRegistrationAndInferedResolution() {
        resolver.register { XYZSessionService() }
        let session: XYZSessionService? = resolver.resolve() as XYZSessionService
        XCTAssertNotNil(session)
    }

    func testRegistrationAndOptionalResolution() {
        resolver.register { XYZSessionService() }
        let session: XYZSessionService? = resolver.optional()
        XCTAssertNotNil(session)
    }

    func testRegistrationAndOptionalResolutionFailure() {
        let session: XYZSessionService? = resolver.optional()
        XCTAssertNil(session)
    }

    func testRegistrationAndResolutionChain() {
        resolver.register { XYZSessionService() }
        resolver.register { XYZService( self.resolver.optional() ) }
        let service: XYZService? = resolver.optional()
        XCTAssertNotNil(service)
        XCTAssertNotNil(service?.session)
    }

}
