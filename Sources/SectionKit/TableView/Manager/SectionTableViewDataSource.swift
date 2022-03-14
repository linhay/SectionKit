//
//  File.swift
//  
//
//  Created by linhey on 2022/3/11.
//

#if canImport(UIKit)
import UIKit

// MARK: - UITableViewDataSource
class SectionTableViewDataSource: NSObject, UITableViewDataSource {
    
    let sectionEvent = SectionDelegate<Int, SectionTableProtocol>()
    let count = SectionDelegate<Void, Int>()
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return count.call() ?? 0
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionEvent.call(section)?.itemCount ?? 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return sectionEvent.call(indexPath.section)?.item(at: indexPath.item) ?? UITableViewCell()
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return sectionEvent.call(indexPath.section)?.canEditItem(at: indexPath.item) ?? false
    }
    
    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return sectionEvent.call(indexPath.section)?.canMove(at: indexPath.item) ?? false
    }
    
    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == destinationIndexPath.section {
            sectionEvent.call(sourceIndexPath.section)?.move(from: sourceIndexPath, to: destinationIndexPath)
        } else {
            sectionEvent.call(sourceIndexPath.section)?.move(from: sourceIndexPath, to: destinationIndexPath)
            sectionEvent.call(destinationIndexPath.section)?.move(from: sourceIndexPath, to: destinationIndexPath)
        }
    }
    
}
#endif
