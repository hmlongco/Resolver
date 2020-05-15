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

    func testSingleArgument() {
        resolver.register { (r, a) -> XYZArgumentService in
            XCTAssert(a()!)
            return XYZArgumentService(condition: a[0]!)
        }
        let service: XYZArgumentService? = resolver.optional(args: true)
        XCTAssertNotNil(service)
        XCTAssert(service?.condition == true)
        XCTAssert(service?.string == "Barney")
    }

    func testPropertiesSingleArgument() {
        resolver.register { XYZArgumentService() }
            .resolveProperties { (r, s, a) in
                XCTAssert(a[0]!) // type inferred
                s.condition = a[0]!
        }
        let service: XYZArgumentService? = resolver.optional(args: true)
        XCTAssertNotNil(service)
        XCTAssert(service?.condition == true)
        XCTAssert(service?.string == "Barney")
    }

    func testSingleArgumentFunction() {
        resolver.register { (r, a) -> XYZArgumentService in
            XCTAssert(a()!)
            return XYZArgumentService(condition: a()!)
        }
        let service: XYZArgumentService? = resolver.optional(arg0: true)
        XCTAssertNotNil(service)
        XCTAssert(service?.condition == true)
        XCTAssert(service?.string == "Barney")
    }

    func testPropertiesSingleArgumenttFunction() {
        resolver.register { XYZArgumentService() }
            .resolveProperties { (r, s, a) in
                XCTAssert(a()!)
                s.condition = a()!
        }
        let service: XYZArgumentService? = resolver.optional(arg0: true)
        XCTAssertNotNil(service)
        XCTAssert(service?.condition == true)
        XCTAssert(service?.string == "Barney")
    }

    func testSingleArgumentPromotion() {
        resolver.register { (r, a) -> XYZArgumentService in
            XCTAssert(a()!)
            return XYZArgumentService(condition: a()!)
        }
        let service: XYZArgumentService? = resolver.optional(args: true)
        XCTAssertNotNil(service)
        XCTAssert(service?.condition == true)
        XCTAssert(service?.string == "Barney")
    }

    func testPropertiesSingleArgumentPromotion() {
        resolver.register { XYZArgumentService() }
            .resolveProperties { (r, s, a) in
                XCTAssert(a()!)
                s.condition = a()!
        }
        let service: XYZArgumentService? = resolver.optional(args: true)
        XCTAssertNotNil(service)
        XCTAssert(service?.condition == true)
        XCTAssert(service?.string == "Barney")
    }

    func testMultipleArguments() {
        resolver.register { (r, a) -> XYZArgumentService in
            let condition: Bool = a[0]!
            XCTAssert(condition)
            let string: String = a[1]!
            XCTAssert(string == "Fred")
            return XYZArgumentService(condition: condition, string: string)
        }
        let service: XYZArgumentService? = resolver.optional(arg0: true, arg1: "Fred")
        XCTAssertNotNil(service)
        XCTAssert(service?.condition == true)
        XCTAssert(service?.string == "Fred")
    }

    func testPropertiesMultipleArguments() {
        resolver.register { XYZArgumentService() }
            .resolveProperties { (r, s, a) in
                XCTAssert(s.condition == false)
                XCTAssert(s.string == "Barney")
                let condition: Bool = a[0]!
                XCTAssert(condition)
                let string: String = a[1]!
                XCTAssert(string == "Fred")
                s.condition = condition
                s.string = string
        }
        let service: XYZArgumentService? = resolver.optional(arg0: true, arg1: "Fred")
        XCTAssertNotNil(service)
        XCTAssert(service?.condition == true)
        XCTAssert(service?.string == "Fred")
    }

}
