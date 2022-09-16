//
//  File.swift
//  
//
//  Created by linhey on 2022/8/12.
//

import Foundation
 
public typealias SKCBaseSectionProtocol = SKCSectionActionProtocol & SKCDataSourceProtocol & SKCDelegateProtocol
public typealias SKCSectionProtocol = SKCBaseSectionProtocol & SKCViewDelegateFlowLayoutProtocol & SKCSectionActionProtocol
