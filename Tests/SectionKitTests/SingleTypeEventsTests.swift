//
//  File.swift
//
//
//  Created by linhey on 2022/4/27.
//

import Combine
import SectionUI
import XCTest

final class wrapperToSingleTypeSectionTests: XCTestCase {
    func testCount() throws {
        for count in 0 ... Int.random(in: 0 ... 1000) {
            XCTAssert(SectionVoidCell.wrapperToSingleTypeSection(count: count).models.count == count)
        }
    }

    func testEvents() throws {
        let section = SectionVoidCell.wrapperToSingleTypeSection(count: 3)
        let view = SKCollectionView()
        view.frame.size = .init(width: 400, height: 400)
        view.manager.reload(section)

        var returnFlag = -1
        section.onCellAction(.selected, block: { result in
            XCTAssert(returnFlag == result.row)
        })
        section.onCellAction(.willDisplay, block: { result in
            XCTAssert(returnFlag == result.row)
        })
        
        section.onCellAction(.didEndDisplay, block: { result in
            XCTAssert(returnFlag == result.row)
        })

        for index in [1, 2, 0, -1, 3] {
            returnFlag = index
            section.item(selected: index)
            section.selectItem(at: index)
            section.deselectItem(at: index)
        }
    }
}
