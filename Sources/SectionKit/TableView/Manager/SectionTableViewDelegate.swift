//
//  File.swift
//  
//
//  Created by linhey on 2022/3/11.
//
#if canImport(UIKit)
import Foundation
import UIKit

// MARK: - UITableViewDelegate
class SectionTableViewDelegate: SectionScrollViewDelegate, UITableViewDelegate {
    
    let sectionEvent = SectionDelegate<Int, SectionTableProtocol>()
    
    private func section(_ indexPath: IndexPath) -> SectionTableProtocol? {
        return sectionEvent.call(indexPath.section)
    }
    
    private func section(_ index: Int) -> SectionTableProtocol? {
        return sectionEvent.call(index)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        section(indexPath)?.item(willDisplay: indexPath.item)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        self.section(section)?.supplementary(willDisplay: view, forElementKind: .header)
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        self.section(section)?.supplementary(willDisplay: view, forElementKind: .footer)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.section(indexPath)?.item(didEndDisplaying: indexPath.item)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        self.section(section)?.supplementary(didEndDisplaying: view, forElementKind: .header)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        self.section(section)?.supplementary(didEndDisplaying: view, forElementKind: .footer)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.section(indexPath)?.itemSize(at: indexPath.item).height ?? .zero
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        self.section(section)?.supplementarySize(kind: .header)?.height ?? .zero
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        self.section(section)?.supplementarySize(kind: .footer)?.height ?? .zero
    }

    // func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    // optional func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat
    // func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        self.section(section)?.supplementary(kind: .header)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        self.section(section)?.supplementary(kind: .footer)
    }

    // func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)

    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        self.section(indexPath)?.item(shouldHighlight: indexPath.item) ?? true
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        self.section(indexPath)?.item(didHighlight: indexPath.item)
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        self.section(indexPath)?.item(didUnhighlight: indexPath.item)
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let item = self.section(indexPath)?.item(willSelect: indexPath.item) else {
            return nil
        }
        return .init(item: item, section: indexPath.section)
    }

    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        guard let item = self.section(indexPath)?.item(willDeselect: indexPath.item) else {
            return nil
        }
        return .init(item: item, section: indexPath.section)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.section(indexPath)?.item(selected: indexPath.item)
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.section(indexPath)?.item(deselected: indexPath.item)
    }

    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        self.section(indexPath)?.item(editingStyle: indexPath.item) ?? .none
    }

    // func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String?

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let actions = self.section(indexPath)?.swipeActions(leading: indexPath.item) else {
            return nil
        }
        return .init(actions: actions)
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let actions = self.section(indexPath)?.swipeActions(trailing: indexPath.item) else {
            return nil
        }
        return .init(actions: actions)
    }

    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        self.section(indexPath)?.item(shouldIndentWhileEditing: indexPath.item) ?? true
    }

    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.section(indexPath)?.item(willBeginEditing: indexPath.item)
    }

    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        self.section(indexPath)?.item(didEndEditing: indexPath.row)
    }

    // func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath
    // func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int
    // func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool
    // func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool
    // func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    // func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath?

    /// Determines if the row at the specified index path should also become selected when focus moves to it.
    /// If the table view's global selectionFollowsFocus is enabled, this method will allow you to override that behavior on a per-index path basis. This method is not called if selectionFollowsFocus is disabled.
    // func tableView(_ tableView: UITableView, selectionFollowsFocusForRowAt indexPath: IndexPath) -> Bool
    // func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool
    // func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool
    // func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath)
    // func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView)

    /**
     * @abstract Called when the interaction begins.
     *
     * @param tableView  This UITableView.
     * @param indexPath  IndexPath of the row for which a configuration is being requested.
     * @param point      Location of the interaction in the table view's coordinate space
     *
     * @return A UIContextMenuConfiguration describing the menu to be presented. Return nil to prevent the interaction from beginning.
     *         Returning an empty configuration causes the interaction to begin then fail with a cancellation effect. You might use this
     *         to indicate to users that it's possible for a menu to be presented from this element, but that there are no actions to
     *         present at this particular time.
     */
    // func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration?

    /**
     * @abstract Called when the interaction begins. Return a UITargetedPreview to override the default preview created by the table view.
     *
     * @param tableView      This UITableView.
     * @param configuration  The configuration of the menu about to be displayed by this interaction.
     */
    // func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?

    /**
     * @abstract Called when the interaction is about to dismiss. Return a UITargetedPreview describing the desired dismissal target.
     * The interaction will animate the presented menu to the target. Use this to customize the dismissal animation.
     *
     * @param tableView      This UITableView.
     * @param configuration  The configuration of the menu displayed by this interaction.
     */
    // func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?

    /**
     * @abstract Called when the interaction is about to "commit" in response to the user tapping the preview.
     *
     * @param tableView      This UITableView.
     * @param configuration  Configuration of the currently displayed menu.
     * @param animator       Commit animator. Add animations to this object to run them alongside the commit transition.
     */
    // func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating)

    /**
     * @abstract Called when the table view is about to display a menu.
     *
     * @param tableView       This UITableView.
     * @param configuration   The configuration of the menu about to be displayed.
     * @param animator        Appearance animator. Add animations to run them alongside the appearance transition.
     */
    // func tableView(_ tableView: UITableView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?)

    /**
     * @abstract Called when the table view's context menu interaction is about to end.
     *
     * @param tableView       This UITableView.
     * @param configuration   Ending configuration.
     * @param animator        Disappearance animator. Add animations to run them alongside the disappearance transition.
     */
    // func tableView(_ tableView: UITableView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?)
}
#endif
