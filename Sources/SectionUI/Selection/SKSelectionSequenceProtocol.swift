//
//  File.swift
//  
//
//  Created by linhey on 2022/9/8.
//

import Foundation

public protocol SKSelectionSequenceProtocol {
    
    associatedtype Element: SKSelectionProtocol
    
    /// 可选元素序列
    var selectableElements: [Element] { get }
    
    /// 已选中某个元素
    /// - Parameters:
    ///   - index: 选中元素索引
    ///   - element: 选中元素
    func element(selected index: Int, element: Element)
    
}

public extension SKSelectionSequenceProtocol {
    func element(selected _: Int, element _: Element) {}
}

public extension SKSelectionSequenceProtocol {
    /// 序列中第一个选中的元素
    func firstSelectedElement() -> Element? {
        return selectableElements.first(where: { $0.isSelected })
    }
    
    /// 序列中第一个选中的元素的索引
    func firstSelectedIndex() -> Int? {
        return selectableElements.firstIndex(where: { $0.isSelected })
    }
    
    /// 已选中的元素
    var selectedElements: [Element] {
        selectableElements.filter(\.isSelected)
    }
    
    /// 已选中的元素序列
    var selectedIndexs: [Int] {
        selectableElements.enumerated().filter { $0.element.isSelected }.map(\.offset)
    }
    
    /// 选中元素
    /// - Parameters:
    ///   - index: 选择序号
    ///   - isUnique: 是否保证选中在当前序列中是否唯一 | default: true
    ///   - needInvert: 是否需要支持反选操作 | default: false
    func select(at index: Int, isUnique: Bool, needInvert: Bool) {
        guard selectableElements.indices.contains(index) else {
            return
        }
        
        let element = selectableElements[index]
        
        guard element.canSelect else {
            return
        }
        
        guard isUnique else {
            element.selection.isSelected = needInvert ? !element.isSelected : true
            self.element(selected: index, element: element)
            return
        }
        
        for (offset, item) in selectableElements.enumerated() {
            if offset == index {
                item.selection.isSelected = needInvert ? !element.isSelected : true
            } else {
                item.selection.isSelected = false
            }
        }
        self.element(selected: index, element: element)
    }
}

public extension SKSelectionSequenceProtocol where Element: Equatable {
    /// 选中指定元素
    /// - Parameters:
    ///   - element: 指定元素
    ///   - needInvert: 是否需要支持反选操作 | default: false
    func select(_ element: Element, needInvert: Bool) {
        guard selectableElements.contains(element) else {
            return
        }
        
        for (offset, item) in selectableElements.enumerated() {
            item.selection.isSelected = needInvert ? !item.isSelected : item == element
            if item == element {
                self.element(selected: offset, element: element)
            }
        }
    }
}
