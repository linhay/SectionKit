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
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sectionEvent.call(indexPath.section)?.item(selected: indexPath.item)
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionEvent.call(section)?.headerView
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionEvent.call(section)?.headerSize.height ?? 0
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sectionEvent.call(indexPath.section)?.itemSize(at: indexPath.row).height ?? 0
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return sectionEvent.call(section)?.footerView
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sectionEvent.call(section)?.footerSize.height ?? 0
    }
    
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let actions = sectionEvent.call(indexPath.section)?.leadingSwipeActions(at: indexPath.item) else {
            return nil
        }
        return UISwipeActionsConfiguration(actions: actions)
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let actions = sectionEvent.call(indexPath.section)?.trailingSwipeActions(at: indexPath.item) else {
            return nil
        }
        return UISwipeActionsConfiguration(actions: actions)
    }
}
#endif
