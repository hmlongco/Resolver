//
//  ResolverInjectedTests.swift
//  ResolverTests
//
//  Created by Michael Long on 3/30/18.
//  Copyright © 2018 com.hmlong. All rights reserved.
//

import XCTest
@testable import Resolver

#if swift(>=5.1)

class BasicInjectedViewController {
    @Injected var service: XYZService
}

class NamedInjectedViewController {
    @Injected(name: "fred") var service: XYZNameService
}

class NamedInjectedViewController2 {
    @Injected var service: XYZNameService
    func viewDidLoad() {
        $service.name = "barney"
    }
}

extension Resolver {
    static var custom = Resolver()
}

class ContainerInjectedViewController {
    @Injected(container: .custom) var service: XYZNameService
}

class ResolverInjectedTests: XCTestCase {

    override func setUp() {
        super.setUp()

        Resolver.main.register { XYZSessionService() }
        Resolver.main.register { XYZService(Resolver.main.optional()) }

        Resolver.main.register(name: "fred") { XYZNameService("fred") }
        Resolver.main.register(name: "barney") { XYZNameService("barney") }

        Resolver.custom.register { XYZNameService("custom") }
    }

    override func tearDown() {
        super.tearDown()
    }

    func testBasicInjection() {
        let vc = BasicInjectedViewController()
        XCTAssertNotNil(vc.service)
        XCTAssertNotNil(vc.service.session)
    }

    func testNamedInjection1() {
        let vc = NamedInjectedViewController()
        XCTAssertNotNil(vc.service)
        XCTAssert(vc.service.name == "fred")
    }

    func testNamedInjection2() {
        let vc = NamedInjectedViewController2()
        vc.viewDidLoad() // emulate
        XCTAssertNotNil(vc.service)
        XCTAssert(vc.service.name == "barney")
    }

    func testContainerInjection() {
        let vc = ContainerInjectedViewController()
        XCTAssertNotNil(vc.service)
        XCTAssert(vc.service.name == "custom")
    }

}

#endif
