// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if canImport(UIKit)
import UIKit

// MARK: - UICollectionViewDelegate && UICollectionViewDataSource
class SectionCollectionViewDelegate: SectionScrollViewDelegate, UICollectionViewDelegate {
    
    let sectionEvent = Delegate<Int, SectionCollectionDriveProtocol>()
    let sectionsEvent = Delegate<Void, LazyMapSequence<LazyFilterSequence<LazyMapSequence<LazySequence<[SectionDynamicType]>.Elements, SectionCollectionDriveProtocol?>>, SectionCollectionDriveProtocol>>()

    func section(from indexPath: IndexPath) -> SectionCollectionDriveProtocol? {
        return sectionEvent.call(indexPath.section)
    }

    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return section(from: indexPath)?.shouldHighlightItem(at: indexPath.item) ?? true
    }

    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        section(from: indexPath)?.didHighlightItem(at: indexPath.item)
    }

    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        section(from: indexPath)?.didUnhighlightItem(at: indexPath.item)
    }

    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return section(from: indexPath)?.shouldSelectItem(at: indexPath.item) ?? true
    }

    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return section(from: indexPath)?.shouldDeselectItem(at: indexPath.item) ?? true
    }

    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        section(from: indexPath)?.didSelectItem(at: indexPath.item)
    }

    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        section(from: indexPath)?.didDeselectItem(at: indexPath.item)
    }
    
    @available(iOS 8.0, *)
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        section(from: indexPath)?.willDisplayItem(at: indexPath.item)
    }

    @available(iOS 8.0, *)
    public func collectionView(_ collectionView: UICollectionView, willDisplaySupplementaryView view: UICollectionReusableView, forElementKind elementKind: String, at indexPath: IndexPath) {
        section(from: indexPath)?.willDisplaySupplementaryView(view: view, forElementKind: elementKind, at: indexPath.item)
    }
    
    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        section(from: indexPath)?.didEndDisplaying(at: indexPath.item)
    }

    @available(iOS 6.0, *)
    public func collectionView(_ collectionView: UICollectionView, didEndDisplayingSupplementaryView view: UICollectionReusableView, forElementOfKind elementKind: String, at indexPath: IndexPath) {
        section(from: indexPath)?.didEndDisplayingSupplementaryView(view: view, forElementKind: elementKind, at: indexPath.item)
    }
//
//    @available(iOS, introduced: 6.0, deprecated: 13.0)
//    public func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool
//
//    @available(iOS, introduced: 6.0, deprecated: 13.0)
//    public func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool
//
//    @available(iOS, introduced: 6.0, deprecated: 13.0)
//    public func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?)
//
//
//    // support for custom transition layout
//    @available(iOS 7.0, *)
//    public func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout
    
    // Focus
//    @available(iOS 9.0, *)
//    public func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool
//
//    @available(iOS 9.0, *)
//    public func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool
//
//    @available(iOS 9.0, *)
//    public func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
//
//    @available(iOS 9.0, *)
//    public func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath?
//
//
//    @available(iOS 9.0, *)
//    public func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath
//
//
//    @available(iOS 9.0, *)
//    public func collectionView(_ collectionView: UICollectionView, targetContentOffsetForProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint // customize the content offset to be applied during transition or update animations
//
    @available(iOS 14.0, *)
    public func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return section(from: indexPath)?.canEditItem(at: indexPath.item) ?? true
    }

// @available(iOS 11.0, *)
// public func collectionView(_ collectionView: UICollectionView, shouldSpringLoadItemAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool

    @available(iOS 13.0, *)
    public func collectionView(_ collectionView: UICollectionView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool {
            section(from: indexPath)?.shouldBeginMultipleSelectionInteraction(at: indexPath.item) ?? false
    }

    @available(iOS 13.0, *)
    public func collectionView(_ collectionView: UICollectionView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath) {
        section(from: indexPath)?.didBeginMultipleSelectionInteraction(at: indexPath.item)
    }

    @available(iOS 13.0, *)
    public func collectionViewDidEndMultipleSelectionInteraction(_ collectionView: UICollectionView) {
        sectionsEvent.call()?.forEach { section in
            section.didEndMultipleSelectionInteraction()
        }
    }

//    @available(iOS 13.0, *)
//    public func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration?
//
//    @available(iOS 13.0, *)
//    public func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?
//
//    @available(iOS 13.0, *)
//    public func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?
//
//    @available(iOS 13.0, *)
//    public func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating)
//
//    @available(iOS 13.2, *)
//    public func collectionView(_ collectionView: UICollectionView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?)
//
//    @available(iOS 13.2, *)
//    public func collectionView(_ collectionView: UICollectionView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?)
    
}
#endif
