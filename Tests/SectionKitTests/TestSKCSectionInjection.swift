//
//  SKCSectionInjection.swift
//  SectionKit
//
//  Created by linhey on 2022/12/5.
//

#if canImport(UIKit)
import UIKit
import XCTest
@testable
import SectionKit

final class TestSKCSectionInjection: XCTestCase {

    var injection: SKCSectionInjection { SKCSectionInjection(index: 1, sectionView: .init(nil)) }

    func testAction1() throws {
        let injection = injection
        var results = [SKCSectionInjection.Action]()
        injection.add(action: .reload) { injection in
            results.append(.reload)
        }
        injection.add(action: .delete) { injection in
            results.append(.delete)
        }
        injection.add(action: .reloadData) { injection in
            results.append(.reloadData)
        }
        XCTAssertFalse(results == [.reload, .delete, .reloadData])
    }
    
    func testAction2() throws {
        let injection = injection
        injection.configuration.setMapAction { action in
            if action == .reload {
                return .reloadData
            }
            return action
        }
        var results = [SKCSectionInjection.Action]()
        injection.add(action: .reload) { injection in
            results.append(.reload)
        }
        injection.add(action: .delete) { injection in
            results.append(.delete)
        }
        injection.add(action: .reloadData) { injection in
            results.append(.reloadData)
        }
        XCTAssertFalse(results == [.reloadData, .delete, .reloadData])
    }
    
    func testAction3() throws {
        SKCSectionInjection.configuration.setMapAction { action in
            if action == .reload {
                return .reloadData
            }
            return action
        }
        var results = [SKCSectionInjection.Action]()
        injection.add(action: .reload) { injection in
            results.append(.reload)
        }
        injection.add(action: .delete) { injection in
            results.append(.delete)
        }
        injection.add(action: .reloadData) { injection in
            results.append(.reloadData)
        }
        XCTAssertFalse(results == [.reloadData, .delete, .reloadData])
        SKCSectionInjection.configuration.setMapAction({ $0 })
    }


}
#endif
