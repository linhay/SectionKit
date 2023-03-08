//
//  SKSelectionStateTests.swift
//  
//
//  Created by linhey on 2023/3/8.
//

import XCTest
import Combine
import SectionUI

class SKSelectionStateTests: XCTestCase {
    
    func testSelectionStateIsEqual() {
        let selectionState1 = SKSelectionState(isSelected: true, canSelect: true, isEnabled: true)
        let selectionState2 = SKSelectionState(isSelected: true, canSelect: true, isEnabled: true)
        let selectionState3 = SKSelectionState(isSelected: false, canSelect: true, isEnabled: true)
        
        XCTAssertEqual(selectionState1, selectionState2)
        XCTAssertNotEqual(selectionState1, selectionState3)
    }
    
    func testSelectionStateSelectionPublishers() {
        let selectionState = SKSelectionState(isSelected: false, canSelect: true, isEnabled: true)
        var selectionChangesCount = 0
        var canSelectChangesCount = 0
        var isEnabledChangesCount = 0
        
        let selectionExpectation = expectation(description: "Selection Publisher should emit")
        let canSelectExpectation = expectation(description: "Can Select Publisher should emit")
        let isEnabledExpectation = expectation(description: "Is Enabled Publisher should emit")
        
        let selectionSubscriber = selectionState.selectedPublisher
            .dropFirst()
            .sink { selection in
                selectionChangesCount += 1
                selectionExpectation.fulfill()
            }
        
        let canSelectSubscriber = selectionState.canSelectPublisher
            .dropFirst()
            .sink { canSelect in
                canSelectChangesCount += 1
                canSelectExpectation.fulfill()
            }
        
        let isEnabledSubscriber = selectionState.isEnabledPublisher
            .dropFirst()
            .sink { isEnabled in
                isEnabledChangesCount += 1
                isEnabledExpectation.fulfill()
            }
        
        // 修改 isSelected 属性，期望 selectionPublisher 发出更新
        selectionState.isSelected = true
        wait(for: [selectionExpectation], timeout: 1)
        XCTAssertEqual(selectionChangesCount, 1)
        
        // 修改 canSelect 属性，期望 canSelectPublisher 发出更新
        selectionState.canSelect = false
        wait(for: [canSelectExpectation], timeout: 1)
        XCTAssertEqual(canSelectChangesCount, 1)
        
        // 修改 isEnabled 属性，期望 isEnabledPublisher 发出更新
        selectionState.isEnabled = false
        wait(for: [isEnabledExpectation], timeout: 1)
        XCTAssertEqual(isEnabledChangesCount, 1)
        
        selectionSubscriber.cancel()
        canSelectSubscriber.cancel()
        isEnabledSubscriber.cancel()
    }

}
