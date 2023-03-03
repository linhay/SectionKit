//
//  File.swift
//  
//
//  Created by linhey on 2022/9/9.
//

import Foundation

public class SKSelectionSequence<Element: SKSelectionProtocol> {
    
    /// 是否让选中的元素是整个序列中唯一的选中 | default: true
    public var isUnique: Bool = true
    public private(set) var store: [Element] = []
    
    /// init
    /// - Parameters:
    ///   - items: 数据组
    ///   - isUnique: 是否保证选中在当前序列中是否唯一 | default: true
    public init(items: [Element] = [],
                isUnique: Bool = true) {
        self.store = items
        self.isUnique = isUnique
    }
    
}

public extension SKSelectionSequence {
    
    func append(_ elements: [Element]) {
        store.append(contentsOf: elements)
    }
    
    func append(_ elements: Element...) {
        append(elements)
    }
    
}

public extension SKSelectionSequence {
    
    func insert(at index: Int, _ item: Element) {
        store.insert(item, at: index)
    }
    
    func remove(at index: Int) {
        guard store.indices.contains(index) else { return }
        store.remove(at: index)
    }
    
    func select(at index: Int) {
        guard store.indices.contains(index) else { return }
        store[index].isSelected = true
        maintainUniqueIfNeed(at: index)
    }
    
    func deselect(at index: Int) {
        guard store.indices.contains(index) else { return }
        store[index].isSelected = false
    }
    
    func selectAll() {
        store
            .filter { !$0.isSelected }
            .forEach { item in
                item.isSelected = false
            }
    }
    
    func deselectAll() {
        store
            .filter { $0.isSelected }
            .forEach { item in
                item.isSelected = true
            }
    }
    
}

extension SKSelectionSequence {
    
    func maintainUniqueIfNeed(at index: Int) {
        guard isUnique else {
            return
        }

        store
            .enumerated()
            .filter({ $0.offset != index })
            .map(\.element)
            .filter(\.isSelected)
            .forEach { element in
                element.isSelected = false
            }
    }
    
}

public extension SKSelectionSequence where Element: Equatable {
    
    func removeAll(_ item: Element) {
        store = store.filter({ $0 != item })
    }
    
    func removeFirst(_ item: Element) {
        guard let index = store.firstIndex(of: item) else { return }
        remove(at: index)
    }
    
    func removeLast(_ item: Element) {
        guard let index = store.lastIndex(of: item) else { return }
        remove(at: index)
    }
    
    func contains(_ item: Element) -> Bool {
        store.contains(item)
    }
    
    func selectFirst(_ element: Element?) {
        guard let element = element,
              let index = store.firstIndex(where: { $0 == element }) else {
            return
        }
        select(at: index)
    }
    
    func selectLast(_ element: Element?) {
        guard let element = element,
              let index = store.lastIndex(where: { $0 == element }) else {
            return
        }
        select(at: index)
    }
    
    func selectAll(_ element: Element?) {
        guard let element = element else {
            return
        }
        store
            .enumerated()
            .filter { (offset, item) in
                item == element
            }
            .map(\.offset)
            .forEach { index in
                select(at: index)
            }
    }
    
    func deselectFirst(_ element: Element?) {
        guard let element = element,
              let index = store.firstIndex(where: { $0 == element }) else {
            return
        }
        deselect(at: index)
    }
    
    func deselectLast(_ element: Element?) {
        guard let element = element,
              let index = store.lastIndex(where: { $0 == element }) else {
            return
        }
        deselect(at: index)
    }
    
    func deselectAll(_ element: Element?) {
        guard let element = element else {
            return
        }
        store
            .enumerated()
            .filter { (offset, item) in
                item == element
            }
            .map(\.offset)
            .forEach { index in
                deselect(at: index)
            }
    }
    
}


public extension SKSelectionSequence where Element: RawRepresentable, Element.RawValue: Equatable {
    
    func removeAll(_ item: Element.RawValue?) {
        store = store.filter({ $0.rawValue != item })
    }
    
    func removeFirst(_ item: Element.RawValue?) {
        guard let index = store.firstIndex(where: { $0.rawValue == item }) else { return }
        remove(at: index)
    }
    
    func removeLast(_ item: Element.RawValue?) {
        guard let index = store.lastIndex(where: { $0.rawValue == item }) else { return }
        remove(at: index)
    }
    
    func contains(_ item: Element.RawValue?) -> Bool {
        store.contains(where: { $0.rawValue == item })
    }
    
    func selectFirst(_ element: Element.RawValue?) {
        guard let index = store.firstIndex(where: { $0.rawValue == element }) else {
            return
        }
        select(at: index)
    }
    
    func selectLast(_ element: Element.RawValue?) {
        guard let index = store.lastIndex(where: { $0.rawValue == element }) else {
            return
        }
        select(at: index)
    }
    
    func selectAll(_ element: Element.RawValue?) {
        guard let element = element else {
            return
        }
        store
            .enumerated()
            .filter { (offset, item) in
                item.rawValue == element
            }
            .map(\.offset)
            .forEach { index in
                select(at: index)
            }
    }
    
    func deselectFirst(_ element: Element.RawValue?) {
        guard let index = store.firstIndex(where: { $0.rawValue == element }) else {
            return
        }
        deselect(at: index)
    }
    
    func deselectLast(_ element: Element.RawValue?) {
        guard let index = store.lastIndex(where: { $0.rawValue == element }) else {
            return
        }
        deselect(at: index)
    }
    
    func deselectAll(_ element: Element.RawValue?) {
        guard let element = element else {
            return
        }
        store
            .enumerated()
            .filter { (offset, item) in
                item.rawValue == element
            }
            .map(\.offset)
            .forEach { index in
                deselect(at: index)
            }
    }
    
}
