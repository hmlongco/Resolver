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

class Foo: Codable {
    let info: String
    
    init(info: String) {
        self.info = info
    }
}

class MutipleArguments {
    let info: String
    let message: String
    
    init(info: String, message: String) {
        self.info = info
        self.message = message
    }
}

class Bar {
    @Injected var foo: Foo
    @Injected(data: "{\"info\":\"some data injected\"}".data(using: .utf8)!) var fooData: Foo
    @LazyInjected var fooLazy: Foo
    @OptionalInjected var fooOptional: Foo?
    @Injected(foo: .init(info: "custom init via extension")) var fooCustomInit: Foo
    @Injected(info: "Info passed by propertywrapper", message: "message") var multipleArguments: MutipleArguments
    
    init() {}
}

extension Injected {
    init(foo: Foo) {
        self.init(arguments: foo)
    }
    
    init(info: String, message: String) {
        self.init(arguments: ["info": info, "message": message])
    }
}

class ResolverInjectedTests: XCTestCase {
    
    let testInfo = "some test info"
    
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
        super.tearDown()
    }
    
    func testResolvedViaInjectedPropertyWrapper() {
        
        // Foo registrations
        
        Resolver.register(Foo.self) { [weak self] in
            do {
                return try JSONDecoder().decode(Foo.self, from: "{\"info\":\"\(self!.testInfo)\"}".data(using: .utf8)!)
            } catch {
                fatalError("\(error)")
            }
        }
        
        Resolver.register(Foo.self, name: "\(Foo.self)DataArgument") { (resolver, arguments) in
            
            do {
                return try JSONDecoder().decode(Foo.self, from: arguments())
            } catch {
                fatalError("\(error)")
            }
        }
        
        Resolver.register(Foo.self, name: "\(Foo.self)Arguments") { (resolver, arguments) in
            arguments()
        }
        
        Resolver.register(MutipleArguments.self, name: "\(MutipleArguments.self)Arguments") { (_, arguments) in
            MutipleArguments(info: arguments("info"), message: arguments("message"))
        }
        
        let bar = Bar()
        
        XCTAssertEqual(bar.foo.info, testInfo)
        XCTAssertEqual(bar.fooLazy.info, testInfo)
        XCTAssertEqual(bar.fooOptional?.info, testInfo)
        XCTAssertEqual(bar.fooData.info, "some data injected")
        XCTAssertEqual(bar.fooCustomInit.info, "custom init via extension")
        XCTAssertEqual(bar.multipleArguments.info, "Info passed by propertywrapper")
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
}

extension String: Swift.Error {
    
}

#endif
