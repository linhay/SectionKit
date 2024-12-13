//
//  SKScrollViewDelegateHandler.swift
//  SectionKit2
//
//  Created by linhey on 2024/7/23.
//

import UIKit

public class SKScrollViewDelegateHandler: SKScrollViewDelegateObserverProtocol {
    
    public var id: String = UUID().uuidString
    public var isEnabled: Bool = true
    
    @discardableResult
    public func didScroll(_ observe: @escaping (_ scrollView: UIScrollView) -> Void) -> Self {
        self.didScrolls.append(observe)
        return self
    }
    
    private var didScrolls: [(_ scrollView: UIScrollView) -> Void] = []
    
    public init() {}
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView, value: Void) {
        guard isEnabled else { return }
        for item in didScrolls {
            item(scrollView)
        }
    }
    
}
