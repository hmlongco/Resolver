//
//  ResolverClassTests.swift
//  ResolverTests
//
//  Created by Michael Long on 3/30/18.
//  Copyright © 2018 com.hmlong. All rights reserved.
//

import XCTest
@testable import Resolver

class ResolverClassTests: XCTestCase {

    var resolver: Resolver!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testRegistrationAndExplicitResolution() {
        let session: XYZSessionService? = Resolver.resolve(XYZSessionService.self)
        XCTAssertNotNil(session)
    }

    func testRegistrationAndInferedResolution() {
        let session: XYZSessionService? = Resolver.resolve() as XYZSessionService
        XCTAssertNotNil(session)
    }

    func testRegistrationAndOptionalResolution() {
        let session: XYZSessionService? = Resolver.optional()
        XCTAssertNotNil(session)
    }

    func testRegistrationAndOptionalResolutionFailure() {
        let unknown: XYZNameService? = Resolver.optional()
        XCTAssertNil(unknown)
    }

    func testRegistrationAndResolutionChain() {
        let service: XYZService? = Resolver.optional()
        XCTAssertNotNil(service)
        XCTAssertNotNil(service?.session)
    }

    func testRegistrationOverwritting() {
        Resolver.register() { XYZNameService("Fred") }
        Resolver.register() { XYZNameService("Barney") }
        let service: XYZNameService? = Resolver.optional()
        XCTAssertNotNil(service)
        XCTAssert(service?.name == "Barney")
    }

    func testRegistrationAndPassedResolver() {
        Resolver.register { XYZSessionService() }
        Resolver.register { (r) -> XYZService in
            return XYZService( r.optional() )
        }
        let service: XYZService? = Resolver.optional()
        XCTAssertNotNil(service)
        XCTAssertNotNil(service?.session)
    }

   func testRegistrationAndResolutionProperties() {
        Resolver.register(name: "Props") { XYZSessionService() }
            .resolveProperties { (r, s) in
                s.name = "updated"
        }
        let session: XYZSessionService? = Resolver.optional(name: "Props")
        XCTAssertNotNil(session)
        XCTAssert(session?.name == "updated")
    }

    func testRegistrationAndResolutionArguments() {
        let service: XYZService? = Resolver.optional(args: true)
        XCTAssertNotNil(service)
        XCTAssertNotNil(service?.session)
    }

    func testRegistrationAndResolutionResolve() {
        let service: XYZService = Resolver.resolve()
        XCTAssertNotNil(service.session)
    }

    func testRegistrationAndResolutionResolveArgs() {
        let service: XYZService = Resolver.resolve(args: true)
        XCTAssertNotNil(service.session)
    }

}

