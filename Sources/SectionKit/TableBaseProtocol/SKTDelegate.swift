//
//  File.swift
//
//
//  Created by linhey on 2023/8/14.
//

import UIKit

class SKTDelegate: SKScrollViewDelegate, UITableViewDelegate {
    
    private var _section: (_ indexPath: IndexPath) -> SKTDelegateProtocol?
    private var _endDisplaySection: (_ indexPath: IndexPath) -> SKTDelegateProtocol?
    private var _sections: () -> any Collection<SKTDelegateProtocol>
    
    private func section(_ indexPath: IndexPath) -> SKTDelegateProtocol? {
        return _section(indexPath)
    }
    
    private func section(_ at: Int) -> SKTDelegateProtocol? {
        return _section(.init(row: 0, section: at))
    }
    
    private func endDisplaySection(_ indexPath: IndexPath) -> SKTDelegateProtocol? {
        return _endDisplaySection(indexPath)
    }
    
    private func sections() -> any Collection<SKTDelegateProtocol> {
        return _sections()
    }
    
    init(section: @escaping (_ indexPath: IndexPath) -> SKTDelegateProtocol?,
         endDisplaySection: @escaping (_ indexPath: IndexPath) -> SKTDelegateProtocol?,
         sections: @escaping () -> any Collection<SKTDelegateProtocol>) {
        self._section = section
        self._sections = sections
        self._endDisplaySection = endDisplaySection
        super.init()
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        section(indexPath)?.item(willDisplay: cell, row: indexPath.item)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        self.section(section)?.supplementary(willDisplay: view, kind: .header)
    }
    
    func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        self.section(section)?.supplementary(willDisplay: view, kind: .footer)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        self.section(indexPath)?.item(didEndDisplaying: cell, row: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingHeaderView view: UIView, forSection section: Int) {
        self.section(section)?.supplementary(didEndDisplaying: view, kind: .header)
    }
    
    func tableView(_ tableView: UITableView, didEndDisplayingFooterView view: UIView, forSection section: Int) {
        self.section(section)?.supplementary(didEndDisplaying: view, kind: .footer)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        self.section(indexPath)?.itemHeight(at: indexPath.row) ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        self.section(section)?.headerHeight ?? 0
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        self.section(section)?.footerHeight ?? 0
    }
    
    //    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    //
    //    func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat
    //
    //    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        self.section(section)?.headerView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        self.section(section)?.footerView
    }
    
    //    optional func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath)
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        self.section(indexPath)?.item(shouldHighlight: indexPath.row) ?? true
    }
    
    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        self.section(indexPath)?.item(didHighlight: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        self.section(indexPath)?.item(didUnhighlight: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        self.section(indexPath)?.item(willSelect: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        self.section(indexPath)?.item(willDeselect: indexPath.item)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.section(indexPath)?.item(selected: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.section(indexPath)?.item(deselected: indexPath.item)
    }
    
    /**
     * @abstract Called to determine if a primary action can be performed for the row at the given indexPath.
     * See @c tableView:performPrimaryActionForRowAtIndexPath: for more details about primary actions.
     *
     * @param tableView This UITableView
     * @param indexPath NSIndexPath of the row
     *
     * @return `YES` if the primary action can be performed; otherwise `NO`. If not implemented defaults to `YES` when not editing
     * and `NO` when editing.
     */
    @available(iOS 16.0, *)
    func tableView(_ tableView: UITableView, canPerformPrimaryActionForRowAt indexPath: IndexPath) -> Bool {
        self.section(indexPath)?.item(canPerformPrimaryAction: indexPath.row) ?? true
    }
    
    /**
     * @abstract Called when the primary action should be performed for the row at the given indexPath.
     *
     * @discussion Primary actions allow you to distinguish between a change of selection (which can be based on focus changes or
     * other indirect selection changes) and distinct user actions. Primary actions are performed when the user selects a cell without extending
     * an existing selection. This is called after @c willSelectRow and @c didSelectRow , regardless of whether the cell's selection
     * state was allowed to change.
     *
     * As an example, use @c didSelectRowAtIndexPath for updating state in the current view controller (i.e. buttons, title, etc) and
     * use the primary action for navigation or showing another split view column.
     *
     * @param tableView This UITableView
     * @param indexPath NSIndexPath of the row to perform the action on
     */
    @available(iOS 16.0, *)
    func tableView(_ tableView: UITableView, performPrimaryActionForRowAt indexPath: IndexPath) {
        self.section(indexPath)?.item(performPrimaryAction: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        self.section(indexPath)?.item(editingStyle: indexPath.row) ?? .none
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        self.section(indexPath)?.item(titleForDeleteConfirmationButton: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        self.section(indexPath)?.item(leadingSwipeActionsConfiguration: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        self.section(indexPath)?.item(trailingSwipeActionsConfiguration: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        self.section(indexPath)?.item(shouldIndentWhileEditing: indexPath.row) ?? true
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        self.section(indexPath)?.item(willEditing: indexPath.row)
        
    }
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        guard let indexPath = indexPath else { return }
        self.section(indexPath)?.item(edited: indexPath.row)
    }
    
    //        @available(iOS 8.0, *)
    //        optional func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath
    
    func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        self.section(indexPath)?.item(indentationLevel: indexPath.row) ?? 0
    }
    
    func tableView(_ tableView: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        self.section(indexPath)?.item(canFocus: indexPath.row) ?? true
    }
    //
    //    @available(iOS 9.0, *)
    //    optional func tableView(_ tableView: UITableView, shouldUpdateFocusIn context: UITableViewFocusUpdateContext) -> Bool
    //
    //    @available(iOS 9.0, *)
    //    optional func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator)
    //
    //    @available(iOS 9.0, *)
    //    optional func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath?
    
    /// Determines if the row at the specified index path should also become selected when focus moves to it.
    /// If the table view's global selectionFollowsFocus is enabled, this method will allow you to override that behavior on a per-index path basis. This method is not called if selectionFollowsFocus is disabled.
    //    @available(iOS 15.0, *)
    //    optional func tableView(_ tableView: UITableView, selectionFollowsFocusForRowAt indexPath: IndexPath) -> Bool
    
    //    @available(iOS 11.0, *)
    //    optional func tableView(_ tableView: UITableView, shouldSpringLoadRowAt indexPath: IndexPath, with context: UISpringLoadedInteractionContext) -> Bool
    
    //    @available(iOS 13.0, *)
    //    optional func tableView(_ tableView: UITableView, shouldBeginMultipleSelectionInteractionAt indexPath: IndexPath) -> Bool
    
    //    @available(iOS 13.0, *)
    //    optional func tableView(_ tableView: UITableView, didBeginMultipleSelectionInteractionAt indexPath: IndexPath)
    
    //    @available(iOS 13.0, *)
    //    optional func tableViewDidEndMultipleSelectionInteraction(_ tableView: UITableView)
    
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
    //    @available(iOS 13.0, *)
    //    optional func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration?
    
    /**
     * @abstract Called when the interaction begins. Return a UITargetedPreview to override the default preview created by the table view.
     *
     * @param tableView      This UITableView.
     * @param configuration  The configuration of the menu about to be displayed by this interaction.
     */
    //    @available(iOS 13.0, *)
    //    optional func tableView(_ tableView: UITableView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?
    
    /**
     * @abstract Called when the interaction is about to dismiss. Return a UITargetedPreview describing the desired dismissal target.
     * The interaction will animate the presented menu to the target. Use this to customize the dismissal animation.
     *
     * @param tableView      This UITableView.
     * @param configuration  The configuration of the menu displayed by this interaction.
     */
    //    @available(iOS 13.0, *)
    //    optional func tableView(_ tableView: UITableView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview?
    
    /**
     * @abstract Called when the interaction is about to "commit" in response to the user tapping the preview.
     *
     * @param tableView      This UITableView.
     * @param configuration  Configuration of the currently displayed menu.
     * @param animator       Commit animator. Add animations to this object to run them alongside the commit transition.
     */
    //    @available(iOS 13.0, *)
    //    optional func tableView(_ tableView: UITableView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating)
    
    /**
     * @abstract Called when the table view is about to display a menu.
     *
     * @param tableView       This UITableView.
     * @param configuration   The configuration of the menu about to be displayed.
     * @param animator        Appearance animator. Add animations to run them alongside the appearance transition.
     */
    //    @available(iOS 14.0, *)
    //    optional func tableView(_ tableView: UITableView, willDisplayContextMenu configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?)
    
    /**
     * @abstract Called when the table view's context menu interaction is about to end.
     *
     * @param tableView       This UITableView.
     * @param configuration   Ending configuration.
     * @param animator        Disappearance animator. Add animations to run them alongside the disappearance transition.
     */
    //    @available(iOS 14.0, *)
    //    optional func tableView(_ tableView: UITableView, willEndContextMenuInteraction configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionAnimating?)
    
}
