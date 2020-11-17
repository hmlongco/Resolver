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
    @Injected(name: "barney") var service: XYZNameService
}

extension Resolver {
    static var custom = Resolver()
}

class ContainerInjectedViewController {
    @Injected(container: .custom) var service: XYZNameService
}

class LazyInjectedViewController {
    @LazyInjected var service: XYZService
}

class WeakInjectedHolder {
    @Injected var service: ABCService
}

class WeakInjectedNotHolder {
    @WeakInjected var service: ABCService?
}

class LazyWeakInjectedViewController {
    let name = "LazyWeakInjectedViewController"
    @Injected var presenter: LazyWeakInjectedPresenter
}

class LazyWeakInjectedPresenter {
    @LazyWeakInjected var viewController: LazyWeakInjectedViewController?
}

class OptionalInjectedViewController {
    @OptionalInjected var service: XYZService?
    @OptionalInjected var notRegistered: NotRegistered?
}

class NotRegistered {
}

class ResolverInjectedTests: XCTestCase {

    override func setUp() {
        super.setUp()

        Resolver.main.register { XYZSessionService() }
        Resolver.main.register { XYZService(Resolver.main.optional()) }
        
        Resolver.main.register { ABCService() }.scope(Resolver.shared)

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
        XCTAssertNotNil(vc.service)
        XCTAssert(vc.service.name == "barney")
    }

    func testContainerInjection() {
        let vc = ContainerInjectedViewController()
        XCTAssertNotNil(vc.service)
        XCTAssert(vc.service.name == "custom")
    }

    func testLazyInjection() {
        let vc = LazyInjectedViewController()
        XCTAssert(vc.$service.isEmpty)
        XCTAssertNotNil(vc.service)
        XCTAssertNotNil(vc.service.session)
        XCTAssert(!vc.$service.isEmpty)
    }
    
    func testWeakInjection() {
        var vcHolder: WeakInjectedHolder? = WeakInjectedHolder()
        let vcWeak = WeakInjectedNotHolder()
        XCTAssertNotNil(vcWeak.service?.name)
        vcHolder = nil
        XCTAssertNil(vcWeak.service)
    }
    
    func testLazyWeakInjection() {
        Resolver.main.register { LazyWeakInjectedViewController() }.scope(Resolver.shared)
        Resolver.main.register { LazyWeakInjectedPresenter() }.scope(Resolver.shared)
        //
        var vc: LazyWeakInjectedViewController? = Resolver.main.resolve(LazyWeakInjectedViewController.self)
        let presenter = Resolver.main.resolve(LazyWeakInjectedPresenter.self)
        XCTAssert(presenter.$viewController.isEmpty)
        XCTAssertNotNil(presenter.viewController?.name)
        vc = nil
        XCTAssertNil(presenter.viewController)
    }

    
    func testOptionalInjection() {
        let vc = OptionalInjectedViewController()
        XCTAssertNotNil(vc.service)
        XCTAssertNil(vc.notRegistered)
    }
}

#endif
