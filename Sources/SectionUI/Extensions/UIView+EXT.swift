//
//  File.swift
//  SectionKit
//
//  Created by linhey on 1/13/25.
//


import SectionKit
import UIKit

public extension SKWrapper where Base: UIView {

    /**
     查找 UIView 所在的 UIViewController

     - Example:

     ```
     guard let vc = CustomView().dxy.viewController else {
     return
     }

     vc.present(CustomViewController(), animated: true, completion: nil)

     ```
     */
    var viewController: UIViewController? {
        var next: UIView? = base
        repeat {
            if let vc = next?.next as? UIViewController {
                return vc
            }
            next = next?.superview
        } while next != nil
        return nil
    }
    
}
