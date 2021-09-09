//
//  ResolverProtocolTests.swift
//  ResolverTests
//
//  Created by Michael Long on 3/30/18.
//  Copyright © 2018 com.hmlong. All rights reserved.
//

import XCTest
@testable import Resolver

class ResolverProtocolTests: XCTestCase {

    var resolver: Resolver!

    override func setUp() {
        super.setUp()
        resolver = Resolver()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testProtocolWithExplicitResolution() {
        resolver.register { XYZCombinedService() as XYZFetching }
        let service: XYZFetching? = resolver.resolve(XYZFetching.self)
        XCTAssertNotNil(service)
        XCTAssert(service?.name == "XYZCombinedService")
    }

    func testProtocolWithInferredResolution() {
        resolver.register { XYZCombinedService() as XYZFetching }
        let service: XYZFetching? = resolver.resolve() as XYZFetching
        XCTAssertNotNil(service)
        XCTAssert(service?.name == "XYZCombinedService")
    }

    func testProtocolWithOptionalResolution() {
        resolver.register { XYZCombinedService() as XYZFetching }
        let service: XYZFetching? = resolver.optional()
        XCTAssertNotNil(service)
        XCTAssert(service?.name == "XYZCombinedService")
    }

    func testMultipleProtocolsWithOptionalResolution() {
        resolver.register { XYZCombinedService() as XYZFetching }
        resolver.register { XYZCombinedService() as XYZUpdating }

        let fetcher: XYZFetching? = resolver.optional()
        XCTAssertNotNil(fetcher)
        XCTAssert(fetcher?.name == "XYZCombinedService")

        let updater: XYZUpdating? = resolver.optional()
        XCTAssertNotNil(updater)
        XCTAssert(updater?.name == "XYZCombinedService")
    }

    func testMultipleProtocolsWithForwarding() {
        resolver.register { self.resolver.resolve() as XYZCombinedService as XYZFetching }
        resolver.register { self.resolver.resolve() as XYZCombinedService as XYZUpdating }
        resolver.register { XYZCombinedService() }

        let service: XYZCombinedService? = resolver.optional()
        XCTAssertNotNil(service)
        XCTAssert(service?.name == "XYZCombinedService")

        let fetcher: XYZFetching? = resolver.optional()
        XCTAssertNotNil(fetcher)
        XCTAssert(fetcher?.name == "XYZCombinedService")

        let updater: XYZUpdating? = resolver.optional()
        XCTAssertNotNil(updater)
        XCTAssert(updater?.name == "XYZCombinedService")
    }

    func testMultipleProtocolsWithImplements() {
        resolver.register { XYZCombinedService() }
            .implements(XYZFetching.self)
            .implements(XYZUpdating.self)

        let service: XYZCombinedService? = resolver.optional()
        XCTAssertNotNil(service)
        XCTAssert(service?.name == "XYZCombinedService")

        let fetcher: XYZFetching? = resolver.optional()
        XCTAssertNotNil(fetcher)
        XCTAssert(fetcher?.name == "XYZCombinedService")

        let updater: XYZUpdating? = resolver.optional()
        XCTAssertNotNil(updater)
        XCTAssert(updater?.name == "XYZCombinedService")
    }

    func testScopeSharedProtocols() {
        resolver.register { XYZSessionService() }
            .implements(XYZSessionProtocol.self)
            .scope(.shared)
        let service1: XYZSessionService? = resolver.optional()
        let protocol1: XYZSessionProtocol? = resolver.optional()
        XCTAssertNotNil(service1)
        XCTAssertNotNil(protocol1)
        if let s1 = service1, let p1 = protocol1 {
            XCTAssert(s1.id == p1.id)
        } else {
            XCTFail("sessions not shared")
        }
    }


}
