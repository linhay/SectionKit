//
//  SelectionTest.swift
//  
//
//  Created by linhey on 2022/9/16.
//

import XCTest
import SectionUI

final class SelectionTest: XCTestCase {

    struct MyElement: SKSelectionProtocol {
        var selection: SectionUI.SKSelectionState = .init()
        let name: String
    }
    
    func testSKSelectionState() throws {
        // 创建一个默认的 SKSelectionState
        let selectionState = SKSelectionState()

        // 检查默认属性值是否已正确设置
        XCTAssertFalse(selectionState.isSelected)
        XCTAssertTrue(selectionState.canSelect)
        XCTAssertTrue(selectionState.isEnabled)

        // 订阅 SKSelectionState 的变化
        var isSelected = false
        var canSelect = true
        var isEnabled = true
        let cancellable = selectionState.changedPublisher.sink { state in
            isSelected = state.isSelected
            canSelect = state.canSelect
            isEnabled = state.isEnabled
        }

        // 修改 SKSelectionState 的属性
        selectionState.isSelected = true
        selectionState.canSelect = false
        selectionState.isEnabled = false

        // 检查 SKSelectionState 是否已正确修改
        XCTAssertTrue(isSelected)
        XCTAssertFalse(canSelect)
        XCTAssertFalse(isEnabled)

        // 取消订阅
        cancellable.cancel()

        // 订阅 isSelected 属性的变化
        var selected = false
        let selectedCancellable = selectionState.selectedPublisher.sink { value in
            selected = value
        }

        // 修改 isSelected 属性
        selectionState.isSelected = true

        // 检查 isSelected 属性是否已正确修改
        XCTAssertTrue(selected)

        // 取消订阅
        selectedCancellable.cancel()

        // 订阅 canSelect 属性的变化
        var canSelectValue = true
        let canSelectCancellable = selectionState.canSelectPublisher.sink { value in
            canSelectValue = value
        }

        // 修改 canSelect 属性
        selectionState.canSelect = false

        // 检查 canSelect 属性是否已正确修改
        XCTAssertFalse(canSelectValue)

        // 取消订阅
        canSelectCancellable.cancel()

        // 订阅 isEnabled 属性的变化
        var isEnabledValue = true
        let isEnabledCancellable = selectionState.isEnabledPublisher.sink { value in
            isEnabledValue = value
        }

        // 修改 isEnabled 属性
        selectionState.isEnabled = false

        // 检查 isEnabled 属性是否已正确修改
        XCTAssertFalse(isEnabledValue)

        // 取消订阅
        isEnabledCancellable.cancel()
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
