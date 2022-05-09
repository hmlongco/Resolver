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
    
    struct AppConfig {
        let host1 = "https://www.amazon.com"
        let host2 = "https://www.google.com"
    }
    
    func testResolverNamedStringRegistrations() {
        
        resolver.register { AppConfig() }
        resolver.register(name: "host1") { r in r.resolve(AppConfig.self).host1 }
        resolver.register(name: "host2") { r in r.resolve(AppConfig.self).host2 }

        let host1: String = resolver.resolve(name: "host1")
        let host2: String = resolver.resolve(name: "host2")
        let host3: String? = resolver.optional(name: "host3")
        
        XCTAssert(host1 == "https://www.amazon.com")
        XCTAssert(host2 == "https://www.google.com")
        XCTAssertNil(host3)
    }

    func testResolverNameHashableConformance() {
        
        let registrations: [Resolver.Name:XYZNameService] = [
            .fred : XYZNameService("Fred"),
            .barney : XYZNameService("Barney"),
        ]
        
        registrations.forEach { (name, service) in
            resolver.register(name: name) { service }
        }

        let fred: XYZNameService? = resolver.optional(name: .fred)
        let barney: XYZNameService? = resolver.optional(name: .barney)

        // Check all services resolved
        XCTAssertNotNil(fred)
        XCTAssertNotNil(barney)

        // Check correct service factories called
        XCTAssert(fred?.name == "Fred")
        XCTAssert(barney?.name == "Barney")
    }

    func testResolveAllOfType() {

        resolver.register(name: .fred) { XYZNameService("Fred") }
        resolver.register(name: .barney) { XYZNameService("Barney") }

        let fredAndBarney: [XYZNameService] = resolver.resolveAll()

        // Check all services resolved
        XCTAssertEqual(fredAndBarney.count, 2)
        var foundFred = false
        var foundBarney = false
        for service in fredAndBarney {
            foundFred = foundFred || service.name == "Fred"
            foundBarney = foundBarney || service.name == "Barney"
        }

        XCTAssertTrue(foundFred)
        XCTAssertTrue(foundBarney)
    }

    func testResolveAllOfTypeInMultipleContainers() {

        let childResolver = Resolver()
        let parentResolver = Resolver(child: childResolver)

        parentResolver.register(name: .fred) { XYZNameService("Fred") }
        childResolver.register(name: .barney) { XYZNameService("Barney") }

        let fredAndBarney: [XYZNameService] = parentResolver.resolveAll()

        // Check all services resolved
        XCTAssertEqual(fredAndBarney.count, 2)
        var foundFred = false
        var foundBarney = false
        for service in fredAndBarney {
            foundFred = foundFred || service.name == "Fred"
            foundBarney = foundBarney || service.name == "Barney"
        }

        XCTAssertTrue(foundFred)
        XCTAssertTrue(foundBarney)
    }

    func testResolveAllOfTypeInMultipleContainersWithOverride() {

        let childResolver = Resolver()
        let parentResolver = Resolver(child: childResolver)

        parentResolver.register(name: .fred) { XYZEnhancedNameService("Fred") as XYZNameProtocol }
        childResolver.register(name: .fred) { XYZNameService("Fred") as XYZNameProtocol }
        parentResolver.register(name: .barney) { XYZNameService("Barney") as XYZNameProtocol }

        let fredAndBarney: [XYZNameProtocol] = parentResolver.resolveAll()

        // Check all services resolved
        XCTAssertEqual(fredAndBarney.count, 2)
        var foundFredFromParent = false
        var foundBarney = false
        for service in fredAndBarney {
            foundFredFromParent = foundFredFromParent || (service.name == "Fred" && service is XYZEnhancedNameService)
            foundBarney = foundBarney || service.name == "Barney"
        }

        XCTAssertTrue(foundFredFromParent)
        XCTAssertTrue(foundBarney)
    }
}
