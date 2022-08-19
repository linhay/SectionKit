//
//  File.swift
//  
//
//  Created by linhey on 2022/8/19.
//

import Foundation

public protocol SKCSupplementaryProtocol {
    associatedtype View: SKLoadViewProtocol
    var kind: SKSupplementaryKind { get }
    var type: View.Type { get }
}
