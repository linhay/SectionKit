//
//  File.swift
//  
//
//  Created by linhey on 2023/8/14.
//

import UIKit

public extension SKSectionWrapper where Base: SKConfigurableView & SKLoadViewProtocol {
    
    static func wrapperToTableHeaderFooterView() -> SKTWrapperHeaderFooterView<Base>.Type {
        return Base.wrapperToTableHeaderFooterView()
    }
    
}

public extension SKConfigurableView where Self: SKLoadViewProtocol {
    
    static func wrapperToTableHeaderFooterView() -> SKTWrapperHeaderFooterView<Self>.Type {
        return SKTWrapperHeaderFooterView<Self>.self
    }
    
}

public class SKTWrapperHeaderFooterView<View: SKConfigurableView & SKLoadViewProtocol>: UITableViewHeaderFooterView, SKConfigurableView, SKLoadViewProtocol {
    
    public static func preferredSize(limit size: CGSize, model: View.Model?) -> CGSize {
        View.preferredSize(limit: size, model: model)
    }
    
    public typealias Model = View.Model
    
    
    public func config(_ model: View.Model) {
        wrappedView.config(model)
    }
    
    public private(set) lazy var wrappedView = View()

    public override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        initialize(contentView: self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize(contentView: self)
    }
    
    private func initialize(contentView: UIView) {
        wrappedView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(wrappedView)
        [wrappedView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
         wrappedView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
         wrappedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
         wrappedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)].forEach { constraint in
            constraint.priority = .defaultHigh
            constraint.isActive = true
        }
    }
    
}
