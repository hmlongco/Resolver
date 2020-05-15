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
            return XYZArgumentService(arg0: a[0]!)
        }
        let service: XYZArgumentService? = resolver.optional(arg0: true)
        XCTAssertNotNil(service)
        XCTAssert(service?.arg0 == true)
        XCTAssert(service?.arg1 == "Barney")
    }

    func testPropertiesSingleArgument() {
        resolver.register { XYZArgumentService() }
            .resolveProperties { (r, s, a) in
                XCTAssert(a[0]!) // type inferred
                s.arg0 = a[0]!
        }
        let service: XYZArgumentService? = resolver.optional(arg0: true)
        XCTAssertNotNil(service)
        XCTAssert(service?.arg0 == true)
        XCTAssert(service?.arg1 == "Barney")
    }

    func testSingleArgumentFunction() {
        resolver.register { (r, a) -> XYZArgumentService in
            XCTAssert(a()!)
            return XYZArgumentService(arg0: a()!)
        }
        let service: XYZArgumentService? = resolver.optional(arg0: true)
        XCTAssertNotNil(service)
        XCTAssert(service?.arg0 == true)
        XCTAssert(service?.arg1 == "Barney")
    }

    func testPropertiesSingleArgumenttFunction() {
        resolver.register { XYZArgumentService() }
            .resolveProperties { (r, s, a) in
                XCTAssert(a()!)
                s.arg0 = a()!
        }
        let service: XYZArgumentService? = resolver.optional(arg0: true)
        XCTAssertNotNil(service)
        XCTAssert(service?.arg0 == true)
        XCTAssert(service?.arg1 == "Barney")
    }

    func testSingleArgumentPromotion() {
        resolver.register { (r, a) -> XYZArgumentService in
            XCTAssert(a()!)
            return XYZArgumentService(arg0: a()!)
        }
        let service: XYZArgumentService? = resolver.optional(args: true)
        XCTAssertNotNil(service)
        XCTAssert(service?.arg0 == true)
        XCTAssert(service?.arg1 == "Barney")
    }

    func testPropertiesSingleArgumentPromotion() {
        resolver.register { XYZArgumentService() }
            .resolveProperties { (r, s, a) in
                XCTAssert(a()!)
                s.arg0 = a()!
        }
        let service: XYZArgumentService? = resolver.optional(args: true)
        XCTAssertNotNil(service)
        XCTAssert(service?.arg0 == true)
        XCTAssert(service?.arg1 == "Barney")
    }

    func testMultipleArguments() {
        resolver.register { (r, a) -> XYZArgumentService in
            let arg0: Bool = a[0]!
            XCTAssert(arg0)
            let arg1: String = a[1]!
            XCTAssert(arg1 == "Fred")
            return XYZArgumentService(arg0: arg0, arg1: arg1)
        }
        let service: XYZArgumentService? = resolver.optional(arg0: true, arg1: "Fred")
        XCTAssertNotNil(service)
        XCTAssert(service?.arg0 == true)
        XCTAssert(service?.arg1 == "Fred")
    }

    func testPropertiesMultipleArguments() {
        resolver.register { XYZArgumentService() }
            .resolveProperties { (r, s, a) in
                XCTAssert(s.arg0 == false)
                XCTAssert(s.arg1 == "Barney")
                let arg0: Bool = a[0]!
                XCTAssert(arg0)
                let arg1: String = a[1]!
                XCTAssert(arg1 == "Fred")
                s.arg0 = arg0
                s.arg1 = arg1
        }
        let service: XYZArgumentService? = resolver.optional(arg0: true, arg1: "Fred")
        XCTAssertNotNil(service)
        XCTAssert(service?.arg0 == true)
        XCTAssert(service?.arg1 == "Fred")
    }

}
