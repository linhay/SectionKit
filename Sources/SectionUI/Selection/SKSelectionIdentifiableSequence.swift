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
    
    public private(set) lazy var itemChangedPublisher: AnyPublisher<[ID : Element], Never> = {
        Deferred { [weak self] in
            let subject = PassthroughSubject<[ID: Element], Never>()
            if let self = self {
                self.itemChangedSubject = subject
                for (id, item) in self.store {
                    self.observe(item, by: id)
                }
            }
            return subject
        }.eraseToAnyPublisher()
    }()
    
    private var itemChangedSubject: PassthroughSubject<[ID: Element], Never>?
    
    public private(set) var store: [ID: Element] = [:]
    private var selectedStore: [ID: AnyCancellable] = [:]
    
    /// init
    /// - Parameters:
    ///   - items: 数据组
    ///   - id: 标识数据的ID
    ///   - isUnique: 是否保证选中在当前序列中是否唯一 | default: true
    public init(items: [Element] = [],
                id: KeyPath<Element, ID>,
                isUnique: Bool = true) {
        self.isUnique = isUnique
        items.forEach { element in
            update(element, by: id)
        }
    }
    
}

public extension SKSelectionIdentifiableSequence {
    
    func update(_ element: Element, by id: ID) {
        store[id] = element
        observe(element, by: id)
    }
    
    func update(_ element: Element, by keyPath: KeyPath<Element, ID>) {
        update(element, by: element[keyPath: keyPath])
    }
    
    func update(_ elements: [Element], by keyPath: KeyPath<Element, ID>) {
        for element in elements {
            update(element, by: keyPath)
        }
    }

    func removeAll() {
        store.removeAll()
        selectedStore.removeAll()
    }
    
    func remove(id: ID) {
        store[id] = nil
        selectedStore[id] = nil
    }
    
    func contains(id: ID) -> Bool {
        return store[id] != nil
    }
    
    func deselect(id: ID) {
        store[id]?.isSelected = false
    }
    
    func select(id: ID) {
        store[id]?.isSelected = true
        maintainUniqueIfNeed(exclude: id)
    }
    
}

private extension SKSelectionIdentifiableSequence {
    
    func observe(_ element: Element?, by id: ID) {
        guard itemChangedSubject != nil else {
            return
        }
        selectedStore[id] = element?
            .selectedPublisher
            .dropFirst()
            .sink(receiveValue: { [weak self] flag in
                guard let self = self else { return }
                if flag {
                    self.select(id: id)
                } else {
                    self.deselect(id: id)
                }
                self.itemChangedSubject?.send(self.store)
            })
    }
    
    func maintainUniqueIfNeed(exclude id: ID) {
        guard isUnique else {
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
