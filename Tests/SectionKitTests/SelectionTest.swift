//
//  SelectionTest.swift
//  
//
//  Created by linhey on 2022/9/16.
//

import XCTest
import SectionUI

final class SelectionTest: XCTestCase {

    func testExample() throws {
        let elements = [1,1,2,2,3,3].map { SKSelectionWrapper.init($0) }
        let sequence = SKSelectionSequence(selectableElements: elements)
        XCTAssert(sequence.firstSelectedIndex() == nil)
        XCTAssert(sequence.firstSelectedElement() == nil)
        sequence.selectAll(elements.first)
        XCTAssert(elements[0].isSelected)
        XCTAssert(elements[1].isSelected)
    }

    func testSelectionState() throws {
        let state = SKSelectionState(isSelected: false, canSelect: true, isEnabled: true)
        let cancel = state.changedPublisher.sink(receiveValue: { state in
            print(state.isSelected)
            print(state.isEnabled)
            print(state.canSelect)
        })
        print("1----")
        state.isEnabled  = true
        print("2----")
        state.isSelected = true
        print("3----")
        state.canSelect  = true

        
    }
}
