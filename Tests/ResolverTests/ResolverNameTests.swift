//
//  ResolverNameTests.swift
//  ResolverTests
//
//  Created by Michael Long on 3/30/18.
//  Copyright © 2018 com.hmlong. All rights reserved.
//

import XCTest
@testable import Resolver

class ResolverNameTests: XCTestCase {
    var resolver: Resolver!

    override func setUp() {
        super.setUp()
        resolver = Resolver()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testResolverValidNames() {

        resolver.register(name: .fred) { XYZNameService("Fred") }
        resolver.register(name: .barney) { XYZNameService("Barney") }

        let fred: XYZNameService? = resolver.optional(name: .fred)
        let barney: XYZNameService? = resolver.optional(name: .barney)

        // Check all services resolved
        XCTAssertNotNil(fred)
        XCTAssertNotNil(barney)

        // Check correct service factories called
        XCTAssert(fred?.name == "Fred")
        XCTAssert(barney?.name == "Barney")
    }

    func testResolverInvalidNames() {

        resolver.register(name: .fred) { XYZNameService("Fred") }
        resolver.register(name: .barney) { XYZNameService("Barney") }

        let wilma: XYZNameService? = resolver.optional(name: .wilma)
        XCTAssertNil(wilma)
    }

    func testResolverNamesWithBaseService() {

        resolver.register(name: .fred) { XYZNameService("Fred") }
        resolver.register(name: .barney) { XYZNameService("Barney") }

        resolver.register() { XYZNameService("Base") }

        let fred: XYZNameService? = resolver.optional(name: .fred)
        let barney: XYZNameService? = resolver.optional(name: .barney)
        let base: XYZNameService? = resolver.optional()

        // Check all services resolved
        XCTAssertNotNil(fred)
        XCTAssertNotNil(barney)
        XCTAssertNotNil(base)

        // Check correct service factories called
        XCTAssert(fred?.name == "Fred")
        XCTAssert(barney?.name == "Barney")
        XCTAssert(base?.name == "Base")
    }

    func testResolverNamesWithNoBaseService() {

        resolver.register(name: .fred) { XYZNameService("Fred") }
        resolver.register(name: .barney) { XYZNameService("Barney") }

        let base: XYZNameService? = resolver.optional()
        
        XCTAssertNil(base)
    }

}
