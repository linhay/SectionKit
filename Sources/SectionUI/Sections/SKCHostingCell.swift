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
        var wrappedView: UIView
        if #available(iOS 16.0, *) {
            wrappedView = UIHostingConfiguration {
                ContentView(model: model)
            }
            .margins(.all, 0)
            .makeContentView()
                
        } else {
            let controller = UIHostingController(rootView: ContentView(model: model)
                .frame(width: frame.width, height: frame.height))
            wrappedView = controller.view
        }
        
        self.wrappedView?.removeFromSuperview()
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
    
    public static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return ContentView.preferredSize(limit: size, model: model)
    }
    
}

