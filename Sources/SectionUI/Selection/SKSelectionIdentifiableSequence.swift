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
    
    public private(set) lazy var itemChangedPublisher = observer.eraseToAnyPublisher()
    private let observer = PassthroughSubject<SKSelectionIdentifiableSequence, Never>()
    
    public private(set) var store: [ID: Element] = [:]
    private var cancelables: [ID: AnyCancellable] = [:]
    
    /// init
    /// - Parameters:
    ///   - items: 数据组
    ///   - id: 标识数据的ID
    ///   - isUnique: 是否保证选中在当前序列中是否唯一 | default: true
    public init(items: [Element] = [],
                id: KeyPath<Element, ID>,
                isUnique: Bool = true) {
        self.isUnique = isUnique
        self.update(items, by: id)
    }
    
}

public extension SKSelectionIdentifiableSequence {
    
    func deselect(id: ID) {
        store[id]?.select(false)
    }
    
    func select(id: ID) {
        store[id]?.select(true)
    }
    
}

public extension SKSelectionIdentifiableSequence {
    
    var selectedItems: [Element] {
        store.values.filter(\.isSelected)
    }
    
    var selectedIDs: [ID] {
        store.filter(\.value.isSelected).map(\.key)
    }
    
}

public extension SKSelectionIdentifiableSequence {
    
    func update(_ element: Element, by id: ID) {
        store[id] = element
        cancelables[id] = element.selectedPublisher
            .dropFirst()
            .removeDuplicates()
            .sink { [weak self] flag in
                guard let self = self else { return }
                self.observer.send(self)
                if flag {
                    if self.isUnique {
                        var ids = Set<ID>(self.selectedIDs)
                        ids.remove(id)
                        for id in ids {
                            self.deselect(id: id)
                        }
                    }
                }
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
    
}

public extension SKSelectionIdentifiableSequence {
    
    func removeAll() {
        store.removeAll()
        cancelables.removeAll()
    }
    
    func remove(id: ID) {
        store[id] = nil
        cancelables[id] = nil
    }
    
    func contains(id: ID) -> Bool {
        return store[id] != nil
    }
    
}
