//
//  SKScrollViewDelegateHandler.swift
//  SectionKit2
//
//  Created by linhey on 2024/7/23.
//

import UIKit

public struct SKScrollViewDelegateHandler: SKScrollViewDelegateObserverProtocol {
    
    public var id: String = UUID().uuidString
    
    @discardableResult
    public mutating func didScroll(_ observe: @escaping (_ scrollView: UIScrollView) -> Void) -> Self {
        self.didScrolls.append(observe)
        return self
    }
    
    private var didScrolls: [(_ scrollView: UIScrollView) -> Void] = []
    
    init() {}
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView, value: Void) {
        for item in didScrolls {
            item(scrollView)
        }
    }
    
}
