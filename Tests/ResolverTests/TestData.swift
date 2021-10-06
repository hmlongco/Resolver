//
//  TestData.swift
//  ResolverTests
//
//  Created by Michael Long on 3/30/18.
//  Copyright © 2018 com.hmlong. All rights reserved.
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        register { XYZSessionService() }
        register { XYZService( optional() ) }
    }
}

class XYZViewModel {

    var editMode = true

    var fetcher: XYZFetching
    var updater: XYZUpdating
    var service: XYZService

    init(fetcher: XYZFetching, updater: XYZUpdating, service: XYZService) {
        self.fetcher = fetcher
        self.updater = updater
        self.service = service
    }

    var name: String { return "XYZViewModel" }

}

protocol XYZFetching {
    var name: String { get }
    func string() -> String
}

protocol XYZUpdating {
    var name: String { get }
    func update()
}

class XYZCombinedService: XYZFetching, XYZUpdating {
    var session: XYZSessionService!
    var name: String { return "XYZCombinedService" }
    func string() -> String { return "Hello" }
    func update() { }
}

class XYZService {
    static var counter = 0
    let count: Int
    let session: XYZSessionService?
    var name: String { return "XYZService" }
    init(_ session: XYZSessionService?) {
        self.session = session
        XYZService.counter += 1
        count = XYZService.counter
    }
}

class XYZGraphService {
    let session1: XYZSessionService?
    let session2: XYZSessionService?
    init(_ session1: XYZSessionService?, _ session2: XYZSessionService?) {
        self.session1 = session1
        self.session2 = session2
    }
}

protocol XYZSessionProtocol {
    var id: UUID { get }
}

class XYZSessionService: XYZSessionProtocol {
    let id = UUID()
    var name: String = "XYZSessionService"
}

class XYZSessionService2: XYZSessionProtocol {
    let id = UUID()
    var name: String = "XYZSessionService2"
}

class XYZNameService {
    let id = UUID()
    var name: String
    init(_ name: String) {
        self.name = name
    }
}

class XYZNeverService {
}

class XYZValueService {
    let value1: XYZValue?
    let value2: XYZValue?
    init(_ value1: XYZValue?, _ value2: XYZValue?) {
        self.value1 = value1
        self.value2 = value2
    }
}


protocol XYZArgumentProtocol {
    var condition: Bool { get }
    var string: String { get }
}

class XYZArgumentService: XYZArgumentProtocol {
    var condition: Bool
    var string: String
    init(condition: Bool = false, string: String = "Barney") {
        self.condition = condition
        self.string = string
    }
}

struct XYZValue {
    let id = UUID()
    var name: String { return "XYZValueService" }
}
