//
//  File.swift
//
//
//  Created by linhey on 2023/12/29.
//

import UIKit
import SectionKit
import SwiftUI

@available(iOS 16.0, *)
public extension SKExistModelView where Self: View {
    
    static func wrapperToCollectionCell() -> STCHostingCell<Self>.Type {
        return STCHostingCell<Self>.self
    }
    
}

@available(iOS 16.0, *)
public class STCHostingCell<ContentView: SKExistModelView & View>: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    
    public typealias Model = ContentView.Model
    
    public func config(_ model: ContentView.Model) {
        contentConfiguration = UIHostingConfiguration(content: {
            ContentView.init(model: model)
        })
    }
    
    public static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return ContentView.preferredSize(limit: size, model: model)
    }
    
}
