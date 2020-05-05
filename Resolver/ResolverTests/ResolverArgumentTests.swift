//
//  ResolverArgumentTests.swift
//  ResolverTests
//
//  Created by Michael Long on 05/04/20.
//  Copyright © 2020 com.hmlong. All rights reserved.
//

import XCTest
@testable import Resolver

class XYZEditService {
    var editing: Bool
    var name: String
    init(editing: Bool, name: String) {
        self.editing = editing
        self.name = name
    }
}

class ResolverArgumentTests: XCTestCase {

    var resolver: Resolver!

    override func setUp() {
        super.setUp()
        resolver = Resolver()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testExistingArgument() {
        resolver.register { XYZSessionService() }
        resolver.register { (r, arg) -> XYZService in
            let test: String = arg as? String ?? ""
            XCTAssert(test == "test")
            return XYZService( r.optional() )
        }
        let service: XYZService? = resolver.optional(args: "test")
        XCTAssertNotNil(service)
        XCTAssertNotNil(service?.session)
    }

    func testExistingArgumentPromotion() {
        resolver.register { XYZSessionService() }
        resolver.register { (r, _, args) -> XYZService in
            let test: String = args[0]!
            XCTAssert(test == "test")
            return XYZService( r.optional() )
        }
        let service: XYZService? = resolver.optional(args: "test")
        XCTAssertNotNil(service)
        XCTAssertNotNil(service?.session)
    }

    func testExistingPropertyArgument() {
        resolver.register {
            XYZSessionService()
        }
        .resolveProperties { (r, s, arg) in
            let test: String = arg as? String ?? ""
            XCTAssert(test == "test")
            s.name = test
        }
        let session: XYZSessionService? = resolver.optional(args: "test")
        XCTAssertNotNil(session)
        XCTAssert(session?.name == "test")
    }

    func testExistingPropertyArgumentPromotion() {
        resolver.register {
            XYZSessionService()
        }
        .resolveProperties { (r, s, _, args) in
            let test: String = args[0]!
            XCTAssert(test == "test")
            s.name = test
        }
        let session: XYZSessionService? = resolver.optional(args: "test")
        XCTAssertNotNil(session)
        XCTAssert(session?.name == "test")
    }

    func testResolutionMultipleArguments() {
        resolver.register { (r, _, args) -> XYZEditService in
            let editing: Bool = args[0]!
            XCTAssert(editing == true)
            let name: String = args[1]!
            XCTAssert(name == "Fred")
            return XYZEditService(editing: editing, name: name)
        }
        let service: XYZEditService? = resolver.optional(arg0: true, arg1: "Fred")
        XCTAssertNotNil(service)
        XCTAssert(service?.editing == true)
        XCTAssert(service?.name == "Fred")
    }

    func testResolutionMultipleProperties() {
        resolver.register {
            XYZEditService(editing: false, name: "Barney")
        }
        .resolveProperties { (r, s, _, args) in
            let editing: Bool = args[0]!
            XCTAssert(editing == true)
            let name: String = args[1]!
            XCTAssert(name == "Fred")
            s.editing = editing
            s.name = name
        }
        let service: XYZEditService? = resolver.optional(arg0: true, arg1: "Fred")
        XCTAssertNotNil(service)
        XCTAssert(service?.editing == true)
        XCTAssert(service?.name == "Fred")
    }

    func testResolutionMultipleMissingArguments() {
        resolver.register { (r, _, args) -> XYZEditService in
            let editing: Bool? = args[0]
            XCTAssertNil(editing)
            let name: String? = args[1]
            XCTAssertNil(name)
            return XYZEditService(editing: false, name: "Wilma")
        }
        let service: XYZEditService? = resolver.optional()
        XCTAssertNotNil(service)
        XCTAssertFalse(service?.editing == true)
        XCTAssertFalse(service?.name == "Fred")
    }

    func testRegistrationAndResolutionResolveArgs() {
        let service: XYZService = Resolver.resolve(args: true)
        XCTAssertNotNil(service.session)
    }

}
