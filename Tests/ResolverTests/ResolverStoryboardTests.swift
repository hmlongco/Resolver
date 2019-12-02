//
//  ResolverStoryboardTests.swift
//  ResolverTests
//
//  Created by Michael Long on 3/30/18.
//  Copyright © 2018 com.hmlong. All rights reserved.
//

import XCTest
@testable import Resolver

#if os(iOS)
import UIKit

class MyViewController: UIViewController {
    var service: XYZService!
}

extension MyViewController: StoryboardResolving {
    func resolveViewController() {
        self.service = resolver.optional()
    }
}

class ResolverStoryboardTests: XCTestCase {

    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()
    }

    func testStoryboard() {
        let vc = MyViewController()

        // Simulate resolution trigger from storyboard construction
        vc.resolving = true
        _ = vc.resolving // code coverage

        XCTAssertNotNil(vc.service)
    }

}
#endif
