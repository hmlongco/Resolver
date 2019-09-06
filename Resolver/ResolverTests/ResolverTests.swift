//
//  ResolverTests.swift
//  ResolverTests
//
//  Created by Michael Long on 11/14/17.
//  Copyright © 2017 com.hmlong. All rights reserved.
//

import XCTest
import Resolver

class ResolverTests: XCTestCase {
    
    @Resolve
    private var viewModel: ViewModelType
    
    func testResolve() {
        XCTAssertEqual(viewModel.load(), 5)
    }
}

struct MyViewModel: ViewModelType {
    func load() -> Int { 5 }
}

protocol ViewModelType {
    func load() -> Int
}
