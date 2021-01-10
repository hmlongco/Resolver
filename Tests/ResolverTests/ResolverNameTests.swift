//
//  ResolverNameTests.swift
//  ResolverTests
//
//  Created by Michael Long on 3/30/18.
//  Copyright © 2018 com.hmlong. All rights reserved.
//

import XCTest
@testable import Resolver

extension Resolver.Name {
    static let fred = Self("Fred")
    static let barney = Self("Barney")
}

class ResolverNameTests: XCTestCase {

    var resolver: Resolver!

    override func setUp() {
        super.setUp()
        resolver = Resolver()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testResolverValidNameStrings() {

        resolver.register(name: "Fred") { XYZNameService("Fred") }
        resolver.register(name: "Barney") { XYZNameService("Barney") }

        let fred: XYZNameService? = resolver.optional(name: "Fred")
        let barney: XYZNameService? = resolver.optional(name: "Barney")

        // Check all services resolved
        XCTAssertNotNil(fred)
        XCTAssertNotNil(barney)

        // Check correct service factories called
        XCTAssert(fred?.name == "Fred")
        XCTAssert(barney?.name == "Barney")
    }

    func testResolverValidNameNames() {

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

    func testResolverMixedStringsAndNames() {

        resolver.register(name: .fred) { XYZNameService("Fred") }
        resolver.register(name: "Barney") { XYZNameService("Barney") }

        let fred: XYZNameService? = resolver.optional(name: "Fred")
        let barney: XYZNameService? = resolver.optional(name: .barney)

        // Check all services resolved
        XCTAssertNotNil(fred)
        XCTAssertNotNil(barney)

        // Check correct service factories called
        XCTAssert(fred?.name == "Fred")
        XCTAssert(barney?.name == "Barney")
    }

    func testResolverInvalidNames() {

        resolver.register(name: "Wilma") { XYZNameService("Wilma") }

        let fred: XYZNameService? = resolver.optional(name: "Fred")
        let barney: XYZNameService? = resolver.optional(name: .barney)
        let wilma: XYZNameService? = resolver.optional(name: "Wilma")

        // Check all services resolved
        XCTAssertNil(fred)
        XCTAssertNil(barney)
        XCTAssertNotNil(wilma)

        // Check correct service factories called
        XCTAssert(wilma?.name == "Wilma")
    }

    func testResolverNamesWithBaseService() {

        resolver.register(name: "Fred") { XYZNameService("Fred") }
        resolver.register(name: .barney) { XYZNameService("Barney") }

        resolver.register() { XYZNameService("Base") }

        let fred: XYZNameService? = resolver.optional(name: "Fred")
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

        resolver.register(name: "Fred") { XYZNameService("Fred") }
        resolver.register(name: .barney) { XYZNameService("Barney") }

        let base: XYZNameService? = resolver.optional()

        XCTAssertNil(base)
    }

    func testResolverWithNamedStringVariable() {

        resolver.register(name: "Fred") { XYZNameService("Fred") }
        resolver.register(name: .barney) { XYZNameService("Barney") }

        let string = "Fred"
        let fred: XYZNameService? = resolver.optional(name: .name(fromString: string))

        XCTAssertNotNil(fred)
        XCTAssert(fred?.name == "Fred")

    }

}
