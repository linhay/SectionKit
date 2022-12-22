//
//  File.swift
//  
//
//  Created by linhey on 2022/9/9.
//

import Foundation
import Combine

public class SKSelectionIdentifiableSequence<Element: SKSelectionProtocol, ID: Hashable> {
    
    /// 是否保证选中在当前序列中是否唯一 | default: true
    public var isUnique: Bool
    
    private var store: [ID: Element] = [:]
    private var selectedStore: [ID: AnyCancellable] = [:]
    
    public init(list: [Element] = [],
                id: KeyPath<Element, ID>,
                isUnique: Bool = true) {
        self.isUnique = isUnique
        list.forEach { element in
            update(element, by: id)
        }
    }
    
}

public extension SKSelectionIdentifiableSequence {
    
    func update(_ element: Element, by id: ID) {
        store[id] = element
        if isUnique {
            observe(element, by: id)
        }
    }
    
    func update(_ element: Element, by keyPath: KeyPath<Element, ID>) {
        update(element, by: element[keyPath: keyPath])
    }
    
    func update(_ elements: [Element], by keyPath: KeyPath<Element, ID>) {
        for element in elements {
            update(element, by: keyPath)
        }
    }
    
    func remove(id: ID) {
        store[id] = nil
    }
    
    func contains(id: ID) -> Bool {
        return store[id] != nil
    }
    
    func deselect(id: ID) {
        store[id]?.isSelected = false
    }
    
    func select(id: ID) {
        maintainUniqueIfNeed(exclude: id)
        store[id]?.isSelected = true
    }
    
}

private extension SKSelectionIdentifiableSequence {
    
    func observe(_ element: Element?, by id: ID) {
        selectedStore[id] = element?
            .selectedPublisher
            .filter({ $0 })
            .sink(receiveValue: { [weak self] flag in
                guard let self = self else { return }
                self.maintainUniqueIfNeed(exclude: id)
            })
    }
    
    func maintainUniqueIfNeed(exclude id: ID) {
        guard isUnique,
              let exclude = store[id],
              exclude.isSelected else {
            return
        }

        store
            .filter({ $0.key != id })
            .map(\.value)
            .filter(\.isSelected)
            .forEach { element in
                element.isSelected = false
            }
    }
    
}
