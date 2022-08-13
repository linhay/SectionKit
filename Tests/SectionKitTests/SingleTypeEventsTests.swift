//
//  File.swift
//
//
//  Created by linhey on 2022/4/27.
//

import Combine
import SectionKit
import XCTest

final class SingleTypeWrapperTests: XCTestCase {
    func testCount() throws {
        for count in 0 ... Int.random(in: 0 ... 1000) {
            XCTAssert(SectionVoidCell.singleTypeWrapper(count: count).models.count == count)
        }
    }

    func testEvents() throws {
        let section = SectionVoidCell.singleTypeWrapper(count: 3)
        let view = SKCollectionView()
        view.frame.size = .init(width: 400, height: 400)
        view.manager.update(section)

        var returnFlag = -1
        section.onItemSelected { row in
            XCTAssert(returnFlag == row)
        }
        section.onItemWillDisplay { row in
            XCTAssert(returnFlag == row)
        }
        section.onItemEndDisplay { row in
            XCTAssert(returnFlag == row)
        }

        for index in [1, 2, 0, -1, 3] {
            returnFlag = index
            section.item(selected: index)
            section.item(willDisplay: index)
            section.item(didEndDisplaying: index)
        }
    }
}
