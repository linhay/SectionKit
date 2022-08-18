//
//  File.swift
//  
//
//  Created by linhey on 2022/8/18.
//

import UIKit

protocol SKCSingleTypeSectionProtocol: STCollectionDataSourceProtocol,
                                       SKCSectionActionProtocol,
                                       STCollectionViewDelegateFlowLayoutProtocol,
                                       SKSafeSizeProviderProtocol {
    
    associatedtype Cell: UICollectionViewCell & SKConfigurableView
    typealias Model = Cell.Model
    
    var models: [Model] { get }
    
}

extension SKCSingleTypeSectionProtocol {
    
    var itemCount: Int { models.count }
    var safeSizeProvider: SKSafeSizeProvider { defaultSafeSizeProvider }

}
