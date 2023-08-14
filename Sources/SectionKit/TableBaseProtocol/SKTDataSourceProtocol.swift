//
//  File.swift
//  
//
//  Created by linhey on 2023/8/14.
//

#if canImport(UIKit)
import UIKit

public protocol SKTDataSourceProtocol {
    var sectionIndex: Int? { get }
    
    var titleForHeader: String? { get }
    var titleForFooter: String? { get }
    
    var indexTitle: String? { get }
    var indexTitleRow: Int { get }
    
    var itemCount: Int { get }
    func item(at row: Int) -> UITableViewCell
    
    func item(canMove row: Int) -> Bool
    func item(canEdit row: Int) -> Bool
    func item(edited style: UITableViewCell.EditingStyle, row: Int)
    func move(from source: IndexPath, to destination: IndexPath)
}

public extension SKTDataSourceProtocol {
    
    var sectionIndex: Int? { nil }
    
    @available(iOS 14.0, *)
    var indexTitle: String? { nil }
    @available(iOS 14.0, *)
    var indexTitleRow: Int { 0 }
    
    func supplementary(kind: SKSupplementaryKind, at row: Int) -> UICollectionReusableView? { nil }
    
    func item(canMove row: Int) -> Bool { false }
    func move(from source: IndexPath, to destination: IndexPath) {}
    
}

public extension SKTDataSourceProtocol where Self: SKCSectionActionProtocol {
    
    var sectionIndex: Int? { self.sectionInjection?.index }
    
}

#endif
