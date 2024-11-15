//
//  File.swift
//
//
//  Created by linhey on 2023/12/29.
//

import UIKit
import SectionKit
import SwiftUI

public extension SKExistModelView where Self: View {
    
    static func wrapperToCollectionCell() -> STCHostingCell<Self>.Type {
        return STCHostingCell<Self>.self
    }
    
    static func wrapperToCollectionReusableView() -> STCHostingCell<Self>.Type {
        return STCHostingCell<Self>.self
    }
    
}

public class STCHostingCell<ContentView: SKExistModelView & View>: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    
    public typealias Model = ContentView.Model
    weak var wrappedView: UIView?
    
    public func config(_ model: ContentView.Model) {
        if #available(iOS 16.0, *) {
            contentConfiguration = UIHostingConfiguration(content: {
                ContentView.init(model: model)
            })
            
        } else {
            let view = ContentView(model: model)
            let controller = UIHostingController(rootView: view)
            self.wrappedView?.removeFromSuperview()
            if let wrappedView = controller.view {
                self.wrappedView = wrappedView
                contentView.addSubview(wrappedView)
                wrappedView.translatesAutoresizingMaskIntoConstraints = false
                [wrappedView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
                 wrappedView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
                 wrappedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
                 wrappedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)].forEach { constraint in
                    constraint.isActive = true
                }
            }
        }
    }
    
    public static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return ContentView.preferredSize(limit: size, model: model)
    }
    
}

