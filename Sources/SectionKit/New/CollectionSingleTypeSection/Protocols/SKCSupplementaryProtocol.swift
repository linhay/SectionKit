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
    var config: ((View) -> Void)? { get }
    var size: (_ limitSize: CGSize, _ type: View.Type) -> CGSize { get }
}


extension sk
