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
    
    public private(set) lazy var itemChangedPublisher: AnyPublisher<SKSelectionIdentifiableSequence, Never> = {
        Deferred { [weak self] in
            guard let self = self else {
                return PassthroughSubject<SKSelectionIdentifiableSequence, Never>()
            }
            if let subject = self.itemChangedSubject {
                return subject
            }
            let subject = PassthroughSubject<SKSelectionIdentifiableSequence, Never>()
            self.itemChangedSubject = subject
            self.observeAll()
            return subject
        }.eraseToAnyPublisher()
    }()
    
    private var itemChangedSubject: PassthroughSubject<SKSelectionIdentifiableSequence, Never>?
    
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
        cancelables.removeAll()
    }
    
    func remove(id: ID) {
        store[id] = nil
        cancelables[id] = nil
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
    
    func observeAll() {
        guard itemChangedSubject != nil else {
            return
        }
        for (id, item) in self.store {
            self.observe(item, by: id)
        }
    }
    
    func observe(_ element: Element?, by id: ID) {
        guard itemChangedSubject != nil else {
            return
        }
        guard let element = element else {
            cancelables[id] = nil
            return
        }
        observe(element, by: id)
    }
    
    func observe(_ element: Element, by id: ID) {
        cancelables[id] = element
            .selectedPublisher
            .dropFirst()
            .sink(receiveValue: { [weak self] flag in
                guard let self = self else { return }
                if flag {
                    self.store[id]?.isSelected = true
                    if !self.maintainUniqueIfNeed(exclude: id) {
                        self.itemChangedSubject?.send(self)
                    }
                } else {
                    self.deselect(id: id)
                    self.itemChangedSubject?.send(self)
                }
            })
    }
    
    @discardableResult
    func maintainUniqueIfNeed(exclude id: ID) -> Bool {
        guard isUnique else {
            return false
        }
        
        var result = false
        store
            .filter({ $0.key != id })
            .map(\.value)
            .filter(\.isSelected)
            .forEach { element in
                element.isSelected = false
                result = true
            }
        
        return result
    }
    
}
