//
//  File.swift
//  
//
//  Created by linhey on 2022/4/27.
//

import XCTest
import Combine
@testable import SectionKit

final class SingleTypeWrapperTests: XCTestCase {
    
    func testCount() throws {
        XCTAssert(SectionVoidCell.singleTypeWrapper(count: 0).models.count == 0)
        XCTAssert(SectionVoidCell.singleTypeWrapper(count: 1).models.count == 1)
        XCTAssert(SectionVoidCell.singleTypeWrapper(count: 2).models.count == 2)
    }
    
    @MainActor
    func testEvents() throws {
        let section = SectionVoidCell.singleTypeWrapper(count: 3)
        let view = SectionCollectionView()
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
        
        for index in [1,2,0,-1,3] {
            returnFlag = index
            section.item(selected: index)
            section.item(willDisplay: index)
            section.item(didEndDisplaying: index)
        }
    }
}
