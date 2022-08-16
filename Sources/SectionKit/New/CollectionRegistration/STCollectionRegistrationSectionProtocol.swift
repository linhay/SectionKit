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
    
    var supplementaries: [any STCollectionSupplementaryRegistrationProtocol] { get set }
    var registrations: [any STCollectionCellRegistrationProtocol] { get set }
    var endDisplayStore: STCollectionRegistrationEndDisplayStore { get }

    func prepare(injection: STCollectionSectionInjection?)
}

public extension STCollectionRegistrationSectionProtocol {
    
    func supplementary(_ kind: SKSupplementaryKind, function: StaticString = #function) -> (any STCollectionSupplementaryRegistrationProtocol)? {
        return supplementaries.first(where: { $0.kind == kind })
    }
    
    func registration(at row: Int, function: StaticString = #function) -> (any STCollectionCellRegistrationProtocol)? {
        guard registrations.indices.contains(row) else {
            debugPrint("\(ObjectIdentifier(self))")
            debugPrint("\(function)")
            debugPrint("\(sectionInjection!.index)-\(row)")
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
        (endDisplayStore.registration(at: row) ?? registration(at: row))?.onEndDisplaying?()
    }
    
    func supplementary(willDisplay view: UICollectionReusableView, kind: SKSupplementaryKind, at row: Int) {
        (endDisplayStore.supplementary(kind) ?? supplementary(kind))?.onWillDisplay?()
    }
    
    func supplementary(didEndDisplaying view: UICollectionReusableView, kind: SKSupplementaryKind, at row: Int) {
        (endDisplayStore.supplementary(kind) ?? supplementary(kind))?.onEndDisplaying?()
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


public extension STCollectionRegistrationSectionProtocol {
    
    func prepare(injection: STCollectionSectionInjection?) {
        guard let injection = injection else {
            supplementaries.forEach { item in
                item.injection = nil
            }
            registrations.forEach { item in
                item.injection = nil
            }
            return
        }
        
        supplementaries.forEach { item in
            var item = item
            item.register(sectionView: sectionView)
            item.indexPath = .init(row: 0, section: injection.index)
            var viewInjection = STCollectionRegistrationInjection(index: injection.index)
            item.injection = viewInjection
            viewInjection.add(.reload) { [weak injection] viewInjection in
                guard let sectionView = injection?.sectionView else { return }
                sectionView.reloadSections(.init(integer: viewInjection.index))
            }
        }
        
        registrations.enumerated().forEach { item in
            var element = item.element
            element.register(sectionView: sectionView)
            element.indexPath = .init(row: item.offset, section: injection.index)
            var viewInjection = STCollectionRegistrationInjection(index: item.offset)
            element.injection = viewInjection
            viewInjection.add(.reload) { [weak injection] viewInjection in
                guard let injection = injection,
                      let sectionView = injection.sectionView else {
                    return
                }
                sectionView.reloadItems(at: [.init(item: viewInjection.index, section: injection.index)])
            }
            viewInjection.add(.delete) { [weak injection] viewInjection in
                guard let injection = injection,
                      let sectionView = injection.sectionView else {
                    return
                }
                sectionView.deleteItems(at: [.init(item: viewInjection.index, section: injection.index)])
            }
            
        }
    }
    
    func delete(_ item: any STCollectionSupplementaryRegistrationProtocol) {
        delete([item])
    }
    
    func delete(_ item: any STCollectionCellRegistrationProtocol) {
        delete([item])
    }
    
    func delete(_ items: [any STCollectionSupplementaryRegistrationProtocol]) {
        endDisplayStore.supplementaries.removeAll()
        let set = Set(items.map(\.kind))
        supplementaries = supplementaries.filter({ item in
            if set.contains(item.kind) {
                endDisplayStore.supplementaries[item.kind] = item
                return false
            } else {
                return true
            }
        })
        guard let injection = sectionInjection else { return }
        injection.sectionView?.reloadSections(.init(integer: injection.index))
    }
    
    func delete(_ items: [any STCollectionCellRegistrationProtocol]) {
        endDisplayStore.registrations.removeAll()
        let set = Set(items.compactMap(\.indexPath))
        registrations = registrations
            .filter({ item in
                guard let indexPath = item.indexPath else {
                    return false
                }
                
                if set.contains(indexPath) {
                    endDisplayStore.registrations[indexPath.item] = item
                    return false
                } else {
                    return true
                }
            })
        
        guard let injection = sectionInjection else { return }
        registrations
            .enumerated()
            .forEach { item in
                var element = item.element
                element.indexPath = .init(item: item.offset, section: injection.index)
            }
        injection.sectionView?.deleteItems(at: .init(set))
    }
    
}
