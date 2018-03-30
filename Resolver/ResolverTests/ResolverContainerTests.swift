//
//  ResolverContainerTests.swift
//  ResolverTests
//
//  Created by Michael Long on 3/30/18.
//  Copyright © 2018 com.hmlong. All rights reserved.
//

import XCTest
@testable import Resolver

class ResolverContainerTests: XCTestCase {

    var resolver1: Resolver!
    var resolver2: Resolver!

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testResolverDistinctContainers() {

        resolver1 = Resolver()
        resolver2 = Resolver()

        resolver1.register() { XYZNameService("Fred") }
        resolver2.register() { XYZNameService("Barney") }

        let fred: XYZNameService? = resolver1.optional()
        XCTAssertNotNil(fred)
        XCTAssert(fred?.name == "Fred")

        let barney: XYZNameService? = resolver2.optional()
        XCTAssertNotNil(barney)
        XCTAssert(barney?.name == "Barney")
    }

    func testResolverParentContainers() {

        resolver1 = Resolver()
        resolver2 = Resolver(parent: resolver1)

        resolver1.register() { XYZNameService("Resolver 1") }

        let r1: XYZNameService? = resolver1.optional()
        XCTAssertNotNil(r1)
        XCTAssert(r1?.name == "Resolver 1")

        // should find in parent container
        let r2: XYZNameService? = resolver2.optional()
        XCTAssertNotNil(r2)
        XCTAssert(r2?.name == "Resolver 1")
    }

    func testResolverParentContainerOverload() {

        resolver1 = Resolver()
        resolver2 = Resolver(parent: resolver1)

        resolver1.register() { XYZNameService("Hidden") }
        resolver2.register() { XYZNameService("Resolved") }

        let r1: XYZNameService? = resolver1.optional()
        XCTAssertNotNil(r1)
        XCTAssert(r1?.name == "Hidden")

        // should find in parent container
        let r2: XYZNameService? = resolver2.optional()
        XCTAssertNotNil(r2)
        XCTAssert(r2?.name == "Resolved")
    }

}
