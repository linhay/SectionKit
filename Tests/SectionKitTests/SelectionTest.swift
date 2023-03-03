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
        let elements = [1,1,2,2,3,3].map { SKSelectionWrapper($0) }
        let sequence = SKSelectionSequence(items: elements)
        
        sequence.selectAll(1)
        sequence.selectFirst(1)
        sequence.selectLast(1)
        
        let element = SKSelectionWrapper(1)
        sequence.selectAll(element)
        sequence.selectFirst(element)
        sequence.selectLast(element)
        
        sequence.selectAll()
        sequence.select(at: 0)
        sequence.deselect(at: 0)
    }
    
    func testIdentifiableSequence() throws {
        let elements = [1,1,2,2,3,3].map { SKSelectionWrapper($0) }
        let sequence = SKSelectionIdentifiableSequence(items: elements, id: \.wrappedValue)
        sequence.select(id: 1)
        sequence.deselect(id: 1)
        sequence.update(.init(4), by: \.wrappedValue)
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
