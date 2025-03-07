//
//  SKCMutableTypeSection.swift
//  Example
//
//  Created by linhey on 3/6/25.
//

import Foundation
import SectionUI
import UIKit

extension SKConfigurableView where Self: UICollectionViewCell & SKLoadViewProtocol {
    
    static func wrapperToDifferentTypeBox(_ model: [Model]) -> [SKCDifferentCellItem] {
        model.map { model in
            self.wrapperToDifferentTypeBox(model)
        }
    }
    
    static func wrapperToDifferentTypeBox(_ model: Model) -> SKCDifferentCellItem {
        self.wrapperToDifferentTypeBox({ model })
    }
    
    static func wrapperToDifferentTypeBox(_ model: @escaping () -> Model) -> SKCDifferentCellItem {
        .init()
        .size(with: { limit in
            Self.preferredSize(limit: limit, model: model())
        })
        .dequeue(with: { section, row in
            let cell = section.dequeue(at: row) as Self
            cell.config(model())
            return cell
        })
        .register(with: { section in
            section.register(Self.self)
        })
    }
    
}

extension SKConfigurableView where Self: UICollectionReusableView & SKLoadViewProtocol {
    
    static func wrapperToDifferentTypeBox(_ model: Model) -> SKCDifferentSupplementaryTypeBox {
        self.wrapperToDifferentTypeBox({ model })
    }
    
    static func wrapperToDifferentTypeBox(_ model: @escaping () -> Model) -> SKCDifferentSupplementaryTypeBox {
        .init()
        .register(with: { section, kind in
            section.register(Self.self, for: kind)
        })
        .dequeue { section, kind in
            let cell = section.dequeue(kind: kind) as Self
            cell.config(model())
            return cell
        }
        .size(with: { limit in
            Self.preferredSize(limit: limit, model: model())
        })
    }
    
}

protocol SKCDifferentCellItemProtocol: AnyObject {
    typealias Register = (_ section: SKCDifferentTypeSection) -> Void
    typealias Dequeue  = (_ section: SKCDifferentTypeSection, _ row: Int) -> UICollectionViewCell
    typealias Size     = (_ limit: CGSize) -> CGSize
    typealias CellAction = (_ context: SKCDifferentCellActionContext) -> Void
    var size: Size? { get set }
    var register: Register? { get set }
    var dequeue: Dequeue? { get set }
    var cellActions: [SKCCellActionType: [CellAction]] { get set }
}

extension SKCDifferentCellItemProtocol {
    
    @discardableResult
    func onAction(_ type: SKCCellActionType, action: @escaping CellAction) -> Self {
        var actions = cellActions[type] ?? []
        actions.append(action)
        cellActions[type] = actions
        return self
    }

    @discardableResult
    func dequeue(with value: @escaping Dequeue) -> Self {
        self.dequeue = { section, kind in
            return value(section, kind)
        }
        return self
    }
    
    @discardableResult
    func size(with value: @escaping Size) -> Self {
        self.size = { limit in
            return value(limit)
        }
        return self
    }
    
    @discardableResult
    func register(with value: @escaping Register) -> Self {
        self.register = { section in
            section.taskIfLoaded { section in
                value(section)
            }
        }
        return self
    }
}

extension Array where Element: SKCDifferentCellItemProtocol {
    func onAction(_ type: SKCCellActionType, action: @escaping Element.CellAction) -> Self {
        for item in self {
            item.onAction(type, action: action)
        }
        return self
    }

    func size(with value: @escaping Element.Size) -> Self {
        for item in self {
            item.size(with: value)
        }
        return self
    }
}

public struct SKCDifferentCellActionContext {
    public let section: SKCDifferentTypeSection
    public let row: Int
}

final class SKCDifferentCellItem: SKCDifferentCellItemProtocol {
  
    var id: String?
    var size: Size?
    var register: Register?
    var dequeue: Dequeue?
    var cellActions: [SKCCellActionType: [CellAction]] = [:]
    init() {}
    
}

protocol SKCDifferentSupplementaryTypeProtocol: AnyObject {
    typealias Register = (_ section: SKCDifferentTypeSection, _ kind: SKSupplementaryKind) -> Void
    typealias Dequeue  = (_ section: SKCDifferentTypeSection, _ kind: SKSupplementaryKind) -> UICollectionReusableView
    typealias Size     = (_ limit: CGSize) -> CGSize
    var kind: SKSupplementaryKind? { get set }
    var size: Size? { get set }
    var register: Register? { get set }
    var dequeue: Dequeue? { get set }
}

extension SKCDifferentSupplementaryTypeProtocol {
    
    func dequeue(with value: @escaping Dequeue) -> Self {
        self.dequeue = { section, kind in
            return value(section, kind)
        }
        return self
    }
    
    func size(with value: @escaping Size) -> Self {
        self.size = { limit in
            return value(limit)
        }
        return self
    }
    
    func register(with value: @escaping Register) -> Self {
        self.register = { [weak self] section, kind in
            self?.kind = kind
            section.taskIfLoaded { section in
                value(section, kind)
            }
        }
        return self
    }

}

final class SKCDifferentSupplementaryTypeBox: SKCDifferentSupplementaryTypeProtocol {
    var kind: SKSupplementaryKind?
    var size: Size?
    var register: Register?
    var dequeue: Dequeue?
    
    init() {}
}

public class SKCDifferentTypeSection: SKCSectionProtocol, SKSafeSizeSetterProviderProtocol, SKCSectionLayoutPluginProtocol {

    public typealias ContextBlock<Context, Return> = (_ context: Context) -> Return
    public typealias SupplementaryActionContext = SKCSupplementaryActionContext<SKCDifferentTypeSection>
    
    public typealias LoadedBlock = (_ section: SKCDifferentTypeSection) -> Void
    public typealias SupplementaryActionBlock = ContextBlock<SupplementaryActionContext, Void>

    public var plugins: [SKCSectionLayoutPlugin] = []
    public var cellSafeSizeProvider: SKSafeSizeProvider?
    public lazy var safeSizeProvider: SKSafeSizeProvider = defaultSafeSizeProvider
    
    /// 无数据时隐藏 footerView
    open lazy var hiddenFooterWhenNoItem = true
    /// 无数据时隐藏 headerView
    open lazy var hiddenHeaderWhenNoItem = true
    lazy var items: [any SKCDifferentCellItemProtocol] = []
    lazy var supplementaries: [SKSupplementaryKind: any SKCDifferentSupplementaryTypeProtocol] = [:]
    
    public var itemCount: Int { items.count }
    public var sectionInjection: SKCSectionInjection?
    
    private lazy var loadedTasks: [LoadedBlock] = []
    
    open func config(sectionView: UICollectionView) {
        loadedTasks.forEach { task in
            task(self)
        }
        loadedTasks.removeAll()
    }
    
    open var headerSize: CGSize {
        if hiddenHeaderWhenNoItem, items.isEmpty {
            return .zero
        }
        let kind = SKSupplementaryKind.header
        guard let supplementary = supplementaries[kind] else {
            return .zero
        }
        guard let action = supplementary.size else {
            assertionFailure("item at \(kind.rawValue) size is nil")
            return .zero
        }
        return action(safeSizeProvider.size)
    }
    
    open var headerView: UICollectionReusableView? {
        let kind = SKSupplementaryKind.header
        guard let supplementary = supplementaries[kind] else {
            return nil
        }
        guard let action = supplementary.dequeue else {
            assertionFailure("item at \(kind.rawValue) dequeue is nil")
            return nil
        }
        return action(self, kind)
    }
    
    open var footerSize: CGSize {
        if hiddenFooterWhenNoItem, items.isEmpty {
            return .zero
        }
        let kind = SKSupplementaryKind.footer
        guard let supplementary = supplementaries[kind] else {
            return .zero
        }
        guard let action = supplementary.size else {
            assertionFailure("item at \(kind.rawValue) size is nil")
            return .zero
        }
        return action(safeSizeProvider.size)
    }
    
    open var footerView: UICollectionReusableView? {
        let kind = SKSupplementaryKind.footer
        guard let supplementary = supplementaries[kind] else {
            return nil
        }
        guard let action = supplementary.dequeue else {
            assertionFailure("item at \(kind.rawValue) dequeue is nil")
            return nil
        }
        return action(self, kind)
    }
    
    open func itemSize(at row: Int) -> CGSize {
        guard let action = items[row].size else {
            assertionFailure("item at \(row) size is nil")
            return .zero
        }
        return action(cellSafeSizeProvider?.size ?? safeSizeProvider.size)
    }
    
    open func item(at row: Int) -> UICollectionViewCell {
        guard let action = items[row].dequeue else {
            assertionFailure("item at \(row) dequeue is nil")
            return .init()
        }
        return action(self, row)
    }
    
    open func item(selected row: Int) {
        guard let actions = items[row].cellActions[.selected] else {
            return
        }
        for action in actions {
            action(.init(section: self, row: row))
        }
    }
    
    public func item(willDisplay view: UICollectionViewCell, row: Int) {
        guard let actions = items[row].cellActions[.willDisplay] else {
            return
        }
        for action in actions {
            action(.init(section: self, row: row))
        }
    }
    
    public func item(didEndDisplaying view: UICollectionViewCell, row: Int) {
        guard let actions = items[row].cellActions[.didEndDisplay] else {
            return
        }
        for action in actions {
            action(.init(section: self, row: row))
        }
    }
    
    func render(@SectionArrayResultBuilder<any SKCDifferentCellItemProtocol>
                cells: () -> [any SKCDifferentCellItemProtocol],
                header: (() -> any SKCDifferentSupplementaryTypeProtocol)? = nil,
                footer: (() -> any SKCDifferentSupplementaryTypeProtocol)? = nil) -> Self {
        render(cells(), header: header?(), footer: footer?())
    }
    
    func render(_ items: [any SKCDifferentCellItemProtocol],
                header: (any SKCDifferentSupplementaryTypeProtocol)? = nil,
                footer: (any SKCDifferentSupplementaryTypeProtocol)? = nil) -> Self {
        for item in items {
            guard let action = item.register else {
                assertionFailure("item register is nil")
                continue
            }
            action(self)
        }
        if let header = header {
            header.register?(self, .header)
        }
        if let footer = footer {
            footer.register?(self, .footer)
        }
        self.items = items
        supplementaries.removeAll()
        supplementaries[.header] = header
        supplementaries[.footer] = footer
        return self
    }
}

extension SKCDifferentTypeSection {
    
    func taskIfLoaded(_ task: @escaping LoadedBlock) {
        if self.sectionInjection?.sectionView != nil {
            task(self)
        } else {
            loadedTasks.append(task)
        }
    }
    
}
