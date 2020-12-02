//
//  ResolverArgumentTests.swift
//  ResolverTests
//
//  Created by Michael Long on 11/14/17.
//  Copyright © 2017 com.hmlong. All rights reserved.
//

import XCTest
@testable import Resolver

class ResolverArgumentTests: XCTestCase {

    var resolver: Resolver!

    override func setUp() {
        super.setUp()
        resolver = Resolver()
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func testGetSingleArgument() {
        resolver.register { (r, arg) -> XYZArgumentService in
            XCTAssert(arg.get())
            return XYZArgumentService(condition: arg.get())
        }
        let service: XYZArgumentService? = resolver.optional(args: true)
        XCTAssertNotNil(service)
        XCTAssert(service?.condition == true)
        XCTAssert(service?.string == "Barney")
    }

    func testPropertiesGetSingleArgument() {
        resolver.register { XYZArgumentService() }
            .resolveProperties { (r, s, arg) in
                XCTAssert(arg.get())
                s.condition = arg.get()
        }
        let service: XYZArgumentService? = resolver.optional(args: true)
        XCTAssertNotNil(service)
        XCTAssert(service?.condition == true)
        XCTAssert(service?.string == "Barney")
    }

    func testGetKeyedArguments() {
        resolver.register { (r, args) -> XYZArgumentService in
            let condition: Bool = args.get("condition")
            XCTAssert(condition)
            let string: String = args.get("name")
            XCTAssert(string == "Fred")
            return XYZArgumentService(condition: condition, string: string)
        }
        let service: XYZArgumentService? = resolver.optional(args: ["condition": true, "name": "Fred"])
        XCTAssertNotNil(service)
        XCTAssert(service?.condition == true)
        XCTAssert(service?.string == "Fred")
    }

    func testGetPropertiesKeyedArguments() {
        resolver.register { XYZArgumentService() }
            .resolveProperties { (r, s, args) in
                XCTAssert(s.condition == false)
                XCTAssert(s.string == "Barney")
                let condition: Bool = args.get("condition")
                XCTAssert(condition)
                let string: String = args.get("name")
                XCTAssert(string == "Fred")
                s.condition = condition
                s.string = string
        }
        let service: XYZArgumentService? = resolver.optional(args: ["condition": true, "name": "Fred"])
        XCTAssertNotNil(service)
        XCTAssert(service?.condition == true)
        XCTAssert(service?.string == "Fred")
    }

    #if swift(>=5.2)
    func testSingleArgumentFunction() {
        resolver.register { (r, args) -> XYZArgumentService in
            XCTAssert(args())
            return XYZArgumentService(condition: args())
        }
        let service: XYZArgumentService? = resolver.optional(args: true)
        XCTAssertNotNil(service)
        XCTAssert(service?.condition == true)
        XCTAssert(service?.string == "Barney")
    }

    func testPropertiesSingleArgumentFunction() {
        resolver.register { XYZArgumentService() }
            .resolveProperties { (r, s, args) in
                XCTAssert(args())
                s.condition = args()
        }
        let service: XYZArgumentService? = resolver.optional(args: true)
        XCTAssertNotNil(service)
        XCTAssert(service?.condition == true)
        XCTAssert(service?.string == "Barney")
    }

    func testKeyedArgumentsFunction() {
        resolver.register { (r, args) -> XYZArgumentService in
            let condition: Bool = args("condition")
            XCTAssert(condition)
            let string: String = args("name")
            XCTAssert(string == "Fred")
            return XYZArgumentService(condition: condition, string: string)
        }
        let service: XYZArgumentService? = resolver.optional(args: ["condition": true, "name": "Fred"])
        XCTAssertNotNil(service)
        XCTAssert(service?.condition == true)
        XCTAssert(service?.string == "Fred")
    }

    func testPropertiesKeyedArgumentsFunction() {
        resolver.register { XYZArgumentService() }
            .resolveProperties { (r, s, args) in
                XCTAssert(s.condition == false)
                XCTAssert(s.string == "Barney")
                let condition: Bool = args("condition")
                XCTAssert(condition)
                let string: String = args("name")
                XCTAssert(string == "Fred")
                s.condition = condition
                s.string = string
        }
        let service: XYZArgumentService? = resolver.optional(args: ["condition": true, "name": "Fred"])
        XCTAssertNotNil(service)
        XCTAssert(service?.condition == true)
        XCTAssert(service?.string == "Fred")
    }
    #endif

    func testOptionalArgument() {
        resolver.register { (r, args) -> XYZArgumentService in
            let condition: Bool? = args.optional("condition")
            XCTAssertNotNil(condition)
            XCTAssert(condition == true)
            let missing: Bool? = args.optional("missing")
            XCTAssertNil(missing)
            return XYZArgumentService(condition: condition ?? false)
        }
        let service: XYZArgumentService? = resolver.optional(args: ["condition" : true])
        XCTAssertNotNil(service)
        XCTAssert(service?.condition == true)
        XCTAssert(service?.string == "Barney")
    }


}
