//
//  File.swift
//  
//
//  Created by linhey on 2022/9/8.
//

import Foundation
import Combine

public protocol SKSelectionProtocol {
    var selection: SKSelectionState { get }
}

public extension SKSelectionProtocol {
    
    subscript<T>(dynamicMember keyPath: KeyPath<SKSelectionState, T>) -> T {
        selection[keyPath: keyPath]
    }
    
    var isSelected: Bool {
        get { selection.isSelected }
        nonmutating set { selection.isSelected = newValue }
    }

    var canSelect: Bool {
        get { selection.canSelect }
        nonmutating set { selection.canSelect = newValue }
    }

    /// 是否允许选中或取消选中操作
    var isEnabled: Bool {
        get { selection.isEnabled }
        nonmutating set { selection.isEnabled = newValue }
    }
    
}
