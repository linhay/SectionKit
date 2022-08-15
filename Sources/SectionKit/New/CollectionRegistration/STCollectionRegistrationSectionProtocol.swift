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
    
    var supplementaries: [any STCollectionReusableViewRegistrationProtocol] { get }
    var registrations: [any STCollectionCellRegistrationProtocol] { get }
    
}

public extension STCollectionRegistrationSectionProtocol {

    func supplementary(_ kind: SKSupplementaryKind, function: StaticString = #function) -> (any STCollectionReusableViewRegistrationProtocol)? {
        return supplementaries.first(where: { $0.kind == kind })
    }
    
    func registration(at row: Int, function: StaticString = #function) -> (any STCollectionCellRegistrationProtocol)? {
        guard registrations.indices.contains(row) else {
            debugPrint("\(ObjectIdentifier(self))")
            debugPrint("\(function)")
            debugPrint("\(sectionState!.index)-\(row)")
            debugPrint(self.registrations.map(\.indexPath))
            assertionFailure()
            return nil
        }
        return registrations[row]
    }
    
    var safeSizeProvider: STSafeSizeProvider { defaultSafeSizeProvider }
    
    var itemCount: Int { registrations.count }
    
    func item(at row: Int) -> UICollectionViewCell {
        return registration(at: row)?.dequeue(sectionView: sectionView) ?? .init()
    }
    
    func supplementary(kind: SKSupplementaryKind, at row: Int) -> UICollectionReusableView? {
        supplementary(kind)?.dequeue(sectionView: sectionView, kind: kind)
    }
    
    func itemSize(at row: Int) -> CGSize {
        return registration(at: row)?.preferredSize(limit: safeSizeProvider.size) ?? .zero
    }
    
    var headerView: UICollectionReusableView? {
        supplementary(kind: .header, at: 0)
    }
    
    var footerView: UICollectionReusableView? {
        supplementary(kind: .footer, at: 0)
    }
    
    var headerSize: CGSize {
        supplementary(.header)?.preferredSize(limit: safeSizeProvider.size) ?? .zero
    }
    
    var footerSize: CGSize {
        supplementary(.footer)?.preferredSize(limit: safeSizeProvider.size) ?? .zero
    }
    
    func item(shouldHighlight row: Int) -> Bool {
        registration(at: row)?.shouldHighlight?() ?? true
    }
    
    func item(didHighlight row: Int) {
        registration(at: row)?.onHighlight?()
    }
    
    func item(didUnhighlight row: Int) {
        registration(at: row)?.onUnhighlight?()
    }
    
    func item(shouldSelect row: Int) -> Bool {
        registration(at: row)?.shouldHighlight?() ?? true
    }
    func item(shouldDeselect row: Int) -> Bool {
        registration(at: row)?.shouldDeselect?() ?? true
    }
    
    func item(selected row: Int) {
        registration(at: row)?.onSelected?()
    }
    
    func item(deselected row: Int) {
        registration(at: row)?.onDeselected?()
    }
    
    @available(iOS 16.0, *)
    func item(canPerformPrimaryAction row: Int) -> Bool {
        registration(at: row)?.canPerformPrimaryAction?() ?? true
    }
    
    @available(iOS 16.0, *)
    func item(performPrimaryAction row: Int) {
        registration(at: row)?.onPerformPrimaryAction?()
    }
    
    func item(willDisplay view: UICollectionViewCell, row: Int) {
        registration(at: row)?.onWillDisplay?()
    }
    
    func item(didEndDisplaying view: UICollectionViewCell, row: Int) {
        registration(at: row)?.onEndDisplaying?()
    }
    
    func item(canFocus row: Int) -> Bool {
        registration(at: row)?.canFocus?() ?? true
    }
    
    @available(iOS 15.0, *)
    func item(selectionFollowsFocus row: Int) -> Bool {
        registration(at: row)?.selectionFollowsFocus?() ?? true
    }
    
    @available(iOS 14.0, *)
    func item(canEdit row: Int) -> Bool {
        registration(at: row)?.canEdit?() ?? false
    }
    
    func item(shouldSpringLoad row: Int, with context: UISpringLoadedInteractionContext) -> Bool {
        registration(at: row)?.shouldSpringLoad?(context) ?? true
    }
    
    func item(shouldBeginMultipleSelectionInteraction row: Int) -> Bool {
        registration(at: row)?.shouldBeginMultipleSelectionInteraction?() ?? false
    }
    
    func item(didBeginMultipleSelectionInteraction row: Int) {
        registration(at: row)?.onBeginMultipleSelectionInteraction?()
    }
}
