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

class LazyInjectedArgumentsViewController {
    @LazyInjected var service: XYZArgumentService
    init() {
        $service.args = ["condition": true, "string": "betty"]
    }
}

class OptionalInjectedViewController {
    @OptionalInjected var service: XYZService?
    @OptionalInjected var notRegistered: NotRegistered?
}

class NotRegistered {
}

class ViewControllerWithNetworkService {
    
    class NetworkServiceSingleton {}
    
    @Injected var service: NetworkServiceSingleton
}

protocol InjectedProtocol: class {}

class Controller {
    @Injected var serviceUnique: InjectedProtocol
}

class NetworkService: InjectedProtocol {}

class ResolverInjectedTests: XCTestCase {

    override func setUp() {
        super.setUp()

        Resolver.main.register { XYZSessionService() }
        Resolver.main.register { XYZService(Resolver.main.optional()) }

        Resolver.main.register(name: "fred") { XYZNameService("fred") }
        Resolver.main.register(name: "barney") { XYZNameService("barney") }

        Resolver.main.register { (_, args) in
            XYZArgumentService(condition: args("condition"), string: args("string"))
        }
        
        Resolver.custom.register { XYZNameService("custom") }
    }

    override func tearDown() {
        Resolver.defaultScope = Resolver.graph
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

    func testLazyInjectionArguments() {
        let vc = LazyInjectedArgumentsViewController()
        XCTAssert(vc.$service.isEmpty)
        XCTAssertNotNil(vc.service)
        XCTAssert(vc.service.condition == true)
        XCTAssert(vc.service.string == "betty")
    }

    func testOptionalInjection() {
        let vc = OptionalInjectedViewController()
        XCTAssertNotNil(vc.service)
        XCTAssertNil(vc.notRegistered)
    }
    
    func testApplitionInjected_singletons() {
        
        Resolver.defaultScope = Resolver.application
        Resolver.main = Resolver()
        Resolver.root = Resolver.main
        
        // Not changing default behaviour
        Resolver.register {
            ViewControllerWithNetworkService.NetworkServiceSingleton()
        }
                
        let s1: ViewControllerWithNetworkService.NetworkServiceSingleton = Resolver.resolve()
        let s2: ViewControllerWithNetworkService.NetworkServiceSingleton = Resolver.resolve()
        
        XCTAssertTrue(s1 === s2)
    
        let vc1 = ViewControllerWithNetworkService()
        let vc2 = ViewControllerWithNetworkService()
        
        XCTAssertTrue(vc1.service === vc2.service)
    }
    
    func testGraphInjected_nosignletons() {
        
        Resolver.defaultScope = Resolver.graph
        Resolver.main = Resolver()
        Resolver.root = Resolver.main
        
        // Not changing default behaviour
        Resolver.register {
            ViewControllerWithNetworkService.NetworkServiceSingleton()
        }
        
        let s1: ViewControllerWithNetworkService.NetworkServiceSingleton = Resolver.resolve()
        let s2: ViewControllerWithNetworkService.NetworkServiceSingleton = Resolver.resolve()
        
        XCTAssertTrue(s1 !== s2)
        
        let vc1 = ViewControllerWithNetworkService()
        let vc2 = ViewControllerWithNetworkService()
        
        XCTAssertTrue(vc1.service !== vc2.service)
    }
    
    func testCachedInjected_signletons() {
        
        Resolver.defaultScope = Resolver.cached
        Resolver.main = Resolver()
        Resolver.root = Resolver.main
        
        // Not changing default behaviour
        Resolver.register {
            ViewControllerWithNetworkService.NetworkServiceSingleton()
        }
        
        let s1: ViewControllerWithNetworkService.NetworkServiceSingleton = Resolver.resolve()
        let s2: ViewControllerWithNetworkService.NetworkServiceSingleton = Resolver.resolve()
        
        XCTAssertTrue(s1 === s2)
        
        let vc1 = ViewControllerWithNetworkService()
        let vc2 = ViewControllerWithNetworkService()
        
        XCTAssertTrue(vc1.service === vc2.service)
    }
    
    func testInjectedProtocolApplication_singletons() {
        
        Resolver.defaultScope = Resolver.application
        Resolver.main = Resolver()
        Resolver.root = Resolver.main
        
        Resolver.register { NetworkService() }.implements(InjectedProtocol.self)
        
        let c1 = Controller()
        let c2 = Controller()
        
        XCTAssertTrue(c1.serviceUnique === c2.serviceUnique)
    }
    
    func testInjectedProtocolUnique_no_singletons() {
        
        Resolver.defaultScope = Resolver.unique
        Resolver.main = Resolver()
        Resolver.root = Resolver.main
        
        Resolver.register { NetworkService() }.implements(InjectedProtocol.self)
        
        let c1 = Controller()
        let c2 = Controller()
        
        XCTAssertTrue(c1.serviceUnique !== c2.serviceUnique)
    }
}

#endif
