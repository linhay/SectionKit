//
//  File.swift
//  
//
//  Created by linhey on 2022/8/12.
//

import UIKit

public extension SKConfigurableView where Self: UICollectionViewCell & SKLoadViewProtocol {
    
    static func registration(_ model: Model) -> STCollectionCellRegistration<Self> {
        return .init(model: model, type: Self.self)
    }
    
    static func registration(_ models: [Model]) -> [STCollectionCellRegistration<Self>] {
        return models.map { model in
                .init(model: model, type: Self.self)
        }
    }
    
}

public protocol STCollectionCellRegistrationProtocol: AnyObject, STViewRegistrationProtocol where View: UICollectionViewCell {
    
    typealias BoolBlock = () -> Bool
    typealias VoidBlock = () -> Void
    
    var shouldHighlight: BoolBlock? { get set }
    var shouldSelect: BoolBlock? { get set }
    var shouldDeselect: BoolBlock? { get set }
    var canPerformPrimaryAction: BoolBlock? { get set }
    var canFocus: BoolBlock? { get set }
    var selectionFollowsFocus: BoolBlock? { get set }
    var canEdit: BoolBlock? { get set }
    var shouldBeginMultipleSelectionInteraction: BoolBlock? { get set }
    
    var onHighlight: VoidBlock? { get set }
    var onUnhighlight: VoidBlock? { get set }
    var onSelected: VoidBlock? { get set }
    var onDeselected: VoidBlock? { get set }
    var onPerformPrimaryAction: VoidBlock? { get set }
    var onBeginMultipleSelectionInteraction: VoidBlock? { get set }
    
    var onWillDisplay: VoidBlock? { get set }
    var onEndDisplaying: VoidBlock? { get set }
    
    var shouldSpringLoad: ((UISpringLoadedInteractionContext) -> Bool)?  { get set }

}

extension STCollectionCellRegistrationProtocol where Self: AnyObject {
    
    public func shouldHighlight(_ block: @escaping BoolBlock) -> Self {
        shouldHighlight = block
        return self
    }
    
    public func onHighlight(_ block: @escaping VoidBlock) -> Self {
        onHighlight = block
        return self
    }
    
    public func onUnhighlight(_ block: @escaping VoidBlock) -> Self {
        onUnhighlight = block
        return self
    }
    
    public func shouldSelect(_ block: @escaping BoolBlock) -> Self {
        shouldSelect = block
        return self
    }
    
    public func shouldDeselect(_ block: @escaping BoolBlock) -> Self {
        shouldDeselect = block
        return self
    }
    
    public func onSelected(_ block: @escaping VoidBlock) -> Self {
        onSelected = block
        return self
    }
    
    public func onDeselected(_ block: @escaping VoidBlock) -> Self {
        onDeselected = block
        return self
    }
    
    public func canPerformPrimaryAction(_ block: @escaping BoolBlock) -> Self {
        canPerformPrimaryAction = block
        return self
    }
    
    public func onPerformPrimaryAction(_ block: @escaping VoidBlock) -> Self {
        onPerformPrimaryAction = block
        return self
    }
    
    public func onWillDisplay(_ block: @escaping VoidBlock) -> Self {
        onWillDisplay = block
        return self
    }
    
    public func onEndDisplaying(_ block: @escaping VoidBlock) -> Self {
        onEndDisplaying = block
        return self
    }
    
    public func canFocus(_ block: @escaping BoolBlock) -> Self {
        canFocus = block
        return self
    }
    
    public func selectionFollowsFocus(_ block: @escaping BoolBlock) -> Self {
        selectionFollowsFocus = block
        return self
    }
    
    public func canEdit(_ block: @escaping BoolBlock) -> Self {
        canEdit = block
        return self
    }
    
    public func shouldSpringLoad(_ block: @escaping (UISpringLoadedInteractionContext) -> Bool) -> Self {
        shouldSpringLoad = block
        return self
    }
    
    public func shouldBeginMultipleSelectionInteraction(_ block: @escaping BoolBlock) -> Self {
        shouldBeginMultipleSelectionInteraction = block
        return self
    }
    
    public func onBeginMultipleSelectionInteraction(_ block: @escaping VoidBlock) -> Self {
        onBeginMultipleSelectionInteraction = block
        return self
    }
    
}

public class STCollectionCellRegistration<View: UICollectionViewCell & SKConfigurableView & SKLoadViewProtocol>: STViewRegistration<View>, STCollectionCellRegistrationProtocol {
    
    public var shouldHighlight: BoolBlock?
    public var shouldSelect: BoolBlock?
    public var shouldDeselect: BoolBlock?
    public var canPerformPrimaryAction: BoolBlock?
    public var canFocus: BoolBlock?
    public var selectionFollowsFocus: BoolBlock?
    public var canEdit: BoolBlock?
    public var shouldBeginMultipleSelectionInteraction: BoolBlock?
    
    public var onHighlight: VoidBlock?
    public var onUnhighlight: VoidBlock?
    public var onSelected: VoidBlock?
    public var onDeselected: VoidBlock?
    public var onPerformPrimaryAction: VoidBlock?
    public var onBeginMultipleSelectionInteraction: VoidBlock?
    
    public var onWillDisplay: VoidBlock?
    public var onEndDisplaying: VoidBlock?
    
    public var shouldSpringLoad: ((UISpringLoadedInteractionContext) -> Bool)?
    
}
