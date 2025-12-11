//
//  File.swift
//  SectionKit
//
//  Created by linhey on 12/11/25.
//

import UIKit

public class SKCCellStyle<Cell: UICollectionViewCell & SKConfigurableView & SKLoadViewProtocol>: Identifiable {
    
    public typealias Block = (_ context: SKCCellStyleContext<Cell>) -> Void
    
    public let id: String
    public var style: Block?
    
    public init(id: String = UUID().uuidString, _ style: Block?) {
        self.id = id
        self.style = style
    }
    
}

/// 配置 Cell 样式
public extension SKCSingleTypeSection {
    
    @discardableResult
    func setCellStyle(_ style: SKCCellStyle<Cell>) -> Self {
        cellStyles.append(style)
        return self
    }

    @discardableResult
    func setCellStyle(_ style: @escaping SKCCellStyle<Cell>.Block) -> Self {
        return setCellStyle(.init(style))
    }
    
    @discardableResult
    func setCellStyle<T>(_ path: ReferenceWritableKeyPath<SKCCellStyleContext<Cell>, T>, _ value: T) -> Self {
        return setCellStyle { context in
            context[keyPath: path] = value
        }
    }
    
    @discardableResult
    func setCellStyle<T>(_ path: ReferenceWritableKeyPath<SKCCellStyleContext<Cell>, T?>, _ value: T?) -> Self {
        return setCellStyle { context in
            context[keyPath: path] = value
        }
    }

}

public extension SKCSingleTypeSection {
    
    @discardableResult
    func clearCellAction(_ kind: SKCCellActionType) -> Self {
        cellActions.removeAll(of: kind)
        return self
    }
    
    /// 订阅事件类型
    /// - Parameters:
    ///   - kind: 事件类型
    ///   - block: 回调
    /// - Returns: self
    @discardableResult
    func onCellAction(_ kind: SKCCellActionType, block: @escaping CellActionBlock) -> Self {
        cellActions.append(of: kind, block)
        return self
    }
    
    @discardableResult
    func onAsyncCellAction(_ kind: SKCCellActionType, block: @escaping AsyncCellActionBlock) -> Self {
        return onCellAction(kind) { context in
            Task {
                try await block(context)
            }
        }
    }
    
}

public extension SKCSingleTypeSection {

    @discardableResult
    func clearCellShouldActions(_ kind: SKCCellShouldType) -> Self {
        cellShoulds.removeAll(of: kind)
        return self
    }
    
    func onCellShould(_ kind: SKCCellShouldType, _ value: Bool) -> Self {
        onCellShould(kind) { _ in
            value
        }
    }
    
    func onCellShould(_ kind: SKCCellShouldType, block: @escaping CellShouldBlock) -> Self {
        cellShoulds.append(of: kind, block)
        return self
    }
    
}

public extension SKCSingleTypeSection {
    
    /// 订阅事件类型
    /// - Parameters:
    ///   - kind: 事件类型
    ///   - block: 回调
    /// - Returns: self
    @discardableResult
    func onCellAction<ON: AnyObject>(on: ON, _ kind: SKCCellActionType, block: @escaping CellActionWeakBlock<ON>) -> Self {
        return onCellAction(kind) { [weak on] context in
            guard let on = on else { return }
            block(on, context)
        }
    }
    
}
