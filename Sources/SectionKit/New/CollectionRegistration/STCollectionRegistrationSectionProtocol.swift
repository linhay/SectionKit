//
//  File.swift
//  
//
//  Created by linhey on 2022/8/12.
//

import UIKit

public protocol STCollectionRegistrationSectionProtocol: STCollectionDataSourceProtocol,
                                                         STCollectionActionProtocol,
                                                         STCollectionViewDelegateFlowLayoutProtocol,
                                                         STSafeSizeProviderProtocol {
    
    var supplementaries: [SKSupplementaryKind: any STCollectionReusableViewRegistrationProtocol] { get }
    var registrations: [any STCollectionCellRegistrationProtocol] { get }
    
}

public extension STCollectionRegistrationSectionProtocol {
    
    var safeSizeProvider: STSafeSizeProvider { defaultSafeSizeProvider }
    
    var itemCount: Int { registrations.count }
    
    func item(at row: Int) -> UICollectionViewCell {
        return registrations[row].dequeue(sectionView: sectionView)
    }
    
    func supplementary(kind: SKSupplementaryKind, at row: Int) -> UICollectionReusableView? {
        supplementaries[kind]?.dequeue(sectionView: sectionView, kind: kind)
    }
    
    func itemSize(at row: Int) -> CGSize {
        return registrations[row].preferredSize(limit: safeSizeProvider.size)
    }
    
    var headerView: UICollectionReusableView? {
        supplementary(kind: .header, at: 0)
    }
    
    var headerSize: CGSize {
        supplementaries[.header]?.preferredSize(limit: safeSizeProvider.size) ?? .zero
    }
    
    func item(shouldHighlight row: Int) -> Bool {
        registrations[row].shouldHighlight?() ?? true
    }
    
    func item(didHighlight row: Int) {
        registrations[row].onHighlight?()
    }
    
    func item(didUnhighlight row: Int) {
        registrations[row].onUnhighlight?()
    }
    
    func item(shouldSelect row: Int) -> Bool {
        registrations[row].shouldHighlight?() ?? true
    }
    func item(shouldDeselect row: Int) -> Bool {
        registrations[row].shouldDeselect?() ?? true
    }
    
    func item(selected row: Int) {
        registrations[row].onSelected?()
    }
    
    func item(deselected row: Int) {
        registrations[row].onDeselected?()
    }
    
    @available(iOS 16.0, *)
    func item(canPerformPrimaryAction row: Int) -> Bool {
        registrations[row].canPerformPrimaryAction?() ?? true
    }
    
    @available(iOS 16.0, *)
    func item(performPrimaryAction row: Int) {
        registrations[row].onPerformPrimaryAction?()
    }
    
    func item(willDisplay view: UICollectionViewCell, row: Int) {
        registrations[row].onWillDisplay?()
    }
    
    func item(didEndDisplaying view: UICollectionViewCell, row: Int) {
        registrations[row].onEndDisplaying?()
    }
    
    func item(canFocus row: Int) -> Bool {
        registrations[row].canFocus?() ?? true
    }
    
    @available(iOS 15.0, *)
    func item(selectionFollowsFocus row: Int) -> Bool {
        registrations[row].selectionFollowsFocus?() ?? true
    }
    
    @available(iOS 14.0, *)
    func item(canEdit row: Int) -> Bool {
        registrations[row].canEdit?() ?? false
    }
    
    func item(shouldSpringLoad row: Int, with context: UISpringLoadedInteractionContext) -> Bool {
        registrations[row].shouldSpringLoad?(context) ?? true
    }
    
    func item(shouldBeginMultipleSelectionInteraction row: Int) -> Bool {
        registrations[row].shouldBeginMultipleSelectionInteraction?() ?? false
    }
    
    func item(didBeginMultipleSelectionInteraction row: Int) {
        registrations[row].onBeginMultipleSelectionInteraction?()
    }
}
