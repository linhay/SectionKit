//
//  File.swift
//
//
//  Created by linhey on 2023/8/14.
//

import UIKit

class SKTDataSource: NSObject, UITableViewDataSource {
    
    private var _section: (_ indexPath: IndexPath) -> SKTDataSourceProtocol?
    private var _sections: () -> [SKTDataSourceProtocol]
    
    private func section(_ indexPath: IndexPath) -> SKTDataSourceProtocol? {
        return _section(indexPath)
    }
    
    private func sections() -> [SKTDataSourceProtocol] {
        return _sections()
    }
    
    init(section: @escaping (_ indexPath: IndexPath) -> SKTDataSourceProtocol?,
         sections: @escaping () -> [SKTDataSourceProtocol]) {
        self._section = section
        self._sections = sections
        super.init()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.section(.init(row: 0, section: section))?.itemCount ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let view = section(indexPath)?.item(at: indexPath.row) {
            return view
        } else {
            assertionFailure()
            return .init()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        self.sections().count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        self.section(.init(row: 0, section: section))?.titleForHeader
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        self.section(.init(row: 0, section: section))?.titleForFooter
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        section(indexPath)?.item(canEdit: indexPath.item) ?? true
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        section(indexPath)?.item(canMove: indexPath.item) ?? true
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        self.sections().compactMap(\.indexTitle)
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        if let section = sections().filter({ $0.indexTitle == title }).dropFirst(index).first {
            return section.indexTitleRow
        } else {
            assertionFailure()
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        section(indexPath)?.item(edited: editingStyle, row: indexPath.row)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == destinationIndexPath.section {
            section(sourceIndexPath)?.move(from: sourceIndexPath, to: destinationIndexPath)
        } else {
            section(sourceIndexPath)?.move(from: sourceIndexPath, to: destinationIndexPath)
            section(destinationIndexPath)?.move(from: sourceIndexPath, to: destinationIndexPath)
        }
    }
    
}
