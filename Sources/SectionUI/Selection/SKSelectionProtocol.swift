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
    var isSelected: Bool {
        get { selection.isSelected }
        nonmutating set { selection.isSelected = newValue }
    }
    var canSelect: Bool {
        get { selection.canSelect }
        nonmutating set { selection.canSelect = newValue }
    }
    
    var selectedPublisher: AnyPublisher<Bool, Never> { selection.selectedSubject.eraseToAnyPublisher() }
    var canSelectPublisher: AnyPublisher<Bool, Never> { selection.canSelectSubject.eraseToAnyPublisher() }
    var changedPublisher: AnyPublisher<SKSelectionState, Never> { selection.changedSubject.eraseToAnyPublisher() }
}
