//
//  TestApplication.swift
//  ResolverTests
//
//  Created by Basem Emara on 2019-09-06.
//  Copyright © 2019 com.hmlong. All rights reserved.
//

import XCTest
import Resolver

/// Principle class run before any tests begin, see Info.plist
class TestApplication: NSObject {
    
    override init() {
        super.init()
        
        // Needed early in test life cycle, even before setUp's
        Resolver.register {
            MyViewModel() as ViewModelType
        }
    }
}
