//
//  File.swift
//  
//
//  Created by linhey on 2022/9/9.
//

import Foundation

public class SKSelectionSequence<Element: SKSelectionProtocol>: SKSelectionSequenceProtocol {
    
    public var selectableElements: [Element]
    /// 是否保证选中在当前序列中是否唯一 | default: true
    public var isUnique: Bool = true
    /// 是否需要支持反选操作 | default: false
    public var needInvert: Bool = false
    
    public init(selectableElements: [Element] = [],
                isUnique: Bool = true,
                needInvert: Bool = false) {
        self.selectableElements = selectableElements
        self.isUnique = isUnique
        self.needInvert = needInvert
    }
    
}

public extension SKSelectionSequence {
    
    func append(_ elements: [Element]) {
        selectableElements.append(contentsOf: elements)
    }
    
    func append(_ elements: Element...) {
        append(elements)
    }
    
    func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        try selectableElements.contains(where: predicate)
    }
    
}

public extension SKSelectionSequence {
    
    func select(at index: Int) {
        select(at: index, isUnique: isUnique, needInvert: needInvert)
    }
    
}

public extension SKSelectionSequence where Element: Equatable {
    
    func contains(_ element: Element) -> Bool {
        selectableElements.contains(element)
    }
    
    func selectFirst(_ element: Element) {
        guard let index = selectableElements.firstIndex(where: { $0 == element }) else {
            return
        }
        select(at: index)
    }
    
    func selectLast(_ element: Element) {
        guard let index = selectableElements.lastIndex(where: { $0 == element }) else {
            return
        }
        select(at: index)
    }
    
    func selectAll(_ element: Element) {
        select(element, needInvert: needInvert)
    }
    
}
