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

}
