//
//  File.swift
//  
//
//  Created by linhey on 2022/8/12.
//

import UIKit

public extension SKConfigurableView where Self: UICollectionViewCell & SKLoadViewProtocol {
    
    static func registration(_ model: Model) -> STCollectionCellRegistration<Self, Int> {
        return .init(model: model, type: Self.self)
    }
    
    static func registration(_ models: [Model]) -> [STCollectionCellRegistration<Self, Int>] {
        return models.map { model in
                .init(model: model, type: Self.self)
        }
    }
    
}

public protocol STCollectionCellRegistrationProtocol: AnyObject, STViewRegistrationProtocol where View: UICollectionViewCell {
    
    typealias BoolBlock = () -> Bool
    typealias VoidBlock = () -> Void
    typealias BoolInputBlock = (View.Model) -> Bool
    typealias VoidInputBlock = (View.Model) -> Void
    
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
    
    private func wrapper(_ block: @escaping BoolInputBlock) -> BoolBlock {
        return { [weak self] in
            guard let self = self else { return false }
            return block(self.model)
        }
    }
    
    private func wrapper(_ block: @escaping VoidInputBlock) -> VoidBlock {
        return { [weak self] in
            guard let self = self else { return }
            block(self.model)
        }
    }
    
    public func shouldHighlight(_ block: @escaping BoolInputBlock) -> Self {
        shouldHighlight = wrapper(block)
        return self
    }
    
    public func onHighlight(_ block: @escaping VoidInputBlock) -> Self {
        onHighlight = wrapper(block)
        return self
    }
    
    public func onUnhighlight(_ block: @escaping VoidInputBlock) -> Self {
        onUnhighlight = wrapper(block)
        return self
    }
    
    public func shouldSelect(_ block: @escaping BoolInputBlock) -> Self {
        shouldSelect = wrapper(block)
        return self
    }
    
    public func shouldDeselect(_ block: @escaping BoolInputBlock) -> Self {
        shouldDeselect = wrapper(block)
        return self
    }
    
    public func onSelected(_ block: @escaping VoidInputBlock) -> Self {
        onSelected = wrapper(block)
        return self
    }
    
    public func onDeselected(_ block: @escaping VoidInputBlock) -> Self {
        onDeselected = wrapper(block)
        return self
    }
    
    public func canPerformPrimaryAction(_ block: @escaping BoolInputBlock) -> Self {
        canPerformPrimaryAction = wrapper(block)
        return self
    }
    
    public func onPerformPrimaryAction(_ block: @escaping VoidInputBlock) -> Self {
        onPerformPrimaryAction = wrapper(block)
        return self
    }
    
    public func onWillDisplay(_ block: @escaping VoidInputBlock) -> Self {
        onWillDisplay = wrapper(block)
        return self
    }
    
    public func onEndDisplaying(_ block: @escaping VoidInputBlock) -> Self {
        onEndDisplaying = wrapper(block)
        return self
    }
    
    public func canFocus(_ block: @escaping BoolInputBlock) -> Self {
        canFocus = wrapper(block)
        return self
    }
    
    public func selectionFollowsFocus(_ block: @escaping BoolInputBlock) -> Self {
        selectionFollowsFocus = wrapper(block)
        return self
    }
    
    public func canEdit(_ block: @escaping BoolInputBlock) -> Self {
        canEdit = wrapper(block)
        return self
    }
    
    public func shouldSpringLoad(_ block: @escaping (_ model: View.Model, _ context: UISpringLoadedInteractionContext) -> Bool) -> Self {
        shouldSpringLoad = { [weak self] context -> Bool in
            guard let self = self else { return false }
            return block(self.model, context)
        }
        return self
    }
    
    public func shouldBeginMultipleSelectionInteraction(_ block: @escaping BoolInputBlock) -> Self {
        shouldBeginMultipleSelectionInteraction = wrapper(block)
        return self
    }
    
    public func onBeginMultipleSelectionInteraction(_ block: @escaping VoidInputBlock) -> Self {
        onBeginMultipleSelectionInteraction = wrapper(block)
        return self
    }
    
}

public extension Array where Element: STCollectionCellRegistrationProtocol {
    
    
    func shouldHighlight(_ block: @escaping Element.BoolInputBlock) -> Self {
        return self.map { $0.shouldHighlight(block) }
    }
    
    func onHighlight(_ block: @escaping Element.VoidInputBlock) -> Self {
        return self.map { $0.onHighlight(block) }
    }
    
    func onUnhighlight(_ block: @escaping Element.VoidInputBlock) -> Self {
        return self.map { $0.onUnhighlight(block) }
    }
    
    func shouldSelect(_ block: @escaping Element.BoolInputBlock) -> Self {
        return self.map { $0.shouldSelect(block) }
    }
    
    func shouldDeselect(_ block: @escaping Element.BoolInputBlock) -> Self {
        return self.map { $0.shouldDeselect(block) }
    }
    
    func onSelected(_ block: @escaping Element.VoidInputBlock) -> Self {
        return self.map { $0.onSelected(block) }
    }
    
    func onDeselected(_ block: @escaping Element.VoidInputBlock) -> Self {
        return self.map { $0.onDeselected(block) }
    }
    
    func canPerformPrimaryAction(_ block: @escaping Element.BoolInputBlock) -> Self {
        return self.map { $0.canPerformPrimaryAction(block) }
    }
    
    func onPerformPrimaryAction(_ block: @escaping Element.VoidInputBlock) -> Self {
        return self.map { $0.onPerformPrimaryAction(block) }
    }
    
    func onWillDisplay(_ block: @escaping Element.VoidInputBlock) -> Self {
        return self.map { $0.onWillDisplay(block) }
    }
    
    func onEndDisplaying(_ block: @escaping Element.VoidInputBlock) -> Self {
        return self.map { $0.onEndDisplaying(block) }
    }
    
    func canFocus(_ block: @escaping Element.BoolInputBlock) -> Self {
        return self.map { $0.canFocus(block) }
    }
    
    func selectionFollowsFocus(_ block: @escaping Element.BoolInputBlock) -> Self {
        return self.map { $0.selectionFollowsFocus(block) }
    }
    
    func canEdit(_ block: @escaping Element.BoolInputBlock) -> Self {
        return self.map { $0.canEdit(block) }
    }
    
    func shouldSpringLoad(_ block: @escaping (_ model: Element.View.Model, _ context: UISpringLoadedInteractionContext) -> Bool) -> Self {
        return self.map { $0.shouldSpringLoad(block) }
    }
    
    func shouldBeginMultipleSelectionInteraction(_ block: @escaping Element.BoolInputBlock) -> Self {
        return self.map { $0.shouldBeginMultipleSelectionInteraction(block) }
    }
    
    func onBeginMultipleSelectionInteraction(_ block: @escaping Element.VoidInputBlock) -> Self {
        return self.map { $0.onBeginMultipleSelectionInteraction(block) }
    }
    
}

public class STCollectionCellRegistration<View: UICollectionViewCell & SKConfigurableView & SKLoadViewProtocol, ID: Hashable>: STViewRegistration<View, ID>, STCollectionCellRegistrationProtocol {
    
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
