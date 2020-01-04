//
//  ResolverMultiParamsTests.swift
//  Resolver
//
//  Created by Ahmad Mahmoud on 1/4/20.
//

import XCTest
@testable import Resolver

class InjectableClass {
    
    let firstArgument: String
    let secondArgument: Int
    let thirdArgument: Bool
    let fourthArguemnt: Double
    
    init(_ firstArgument: String, _ secondArgument: Int, _ thirdArgument: Bool, _ fourthArguemnt: Double) {
        self.firstArgument = firstArgument
        self.secondArgument = secondArgument
        self.thirdArgument = thirdArgument
        self.fourthArguemnt = fourthArguemnt
    }
}

class ResolverMultiParamsTests: XCTestCase {

    var resolver: Resolver!

    override func setUp() {
        super.setUp()
        resolver = Resolver()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func testMultipleArguments() {
        // First, Register

        resolver.register { (res, args) -> InjectableClass in
            //
            let firstArgument: String = res.firstArgument(from: args!)!
            let secondArgument: Int = res.secondArgument(from: args!)!
            let thirdArgument: Bool = res.thirdArgument(from: args!)!
            let fourthArguemnt: Double = res.argument(from: args!, argumentNo: 3)!
            //
            return InjectableClass(firstArgument, secondArgument, thirdArgument, fourthArguemnt)
        }
        // Then, Resolve
        let injectableClass: InjectableClass = resolver.resolve(params: "AMS", 11, true, 3.14159)
        // Test Not nil
        XCTAssertNotNil(injectableClass.firstArgument)
        XCTAssertNotNil(injectableClass.secondArgument)
        XCTAssertNotNil(injectableClass.thirdArgument)
        XCTAssertNotNil(injectableClass.fourthArguemnt)
        // Test equality
        assert(injectableClass.firstArgument == "AMS")
        assert(injectableClass.secondArgument == 11)
        assert(injectableClass.thirdArgument == true)
        assert(injectableClass.fourthArguemnt == 3.14159)
    }
}
