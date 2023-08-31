//
//  File.swift
//  
//
//  Created by linhey on 2023/8/14.
//

import UIKit

public extension SKConfigurableView where Self: SKLoadViewProtocol {
    
    static func wrapperToTableCell() -> SKTWrapperCell<Self>.Type {
        return SKTWrapperCell<Self>.self
    }
    
}

public class SKTWrapperCell<View: SKConfigurableView & SKLoadViewProtocol>: UITableViewCell, SKConfigurableView, SKLoadViewProtocol {
    
    public static func preferredSize(limit size: CGSize, model: View.Model?) -> CGSize {
        View.preferredSize(limit: size, model: model)
    }
    
    public typealias Model = View.Model
    
    public func config(_ model: View.Model) {
        wrappedView.config(model)
    }
    
    public private(set) lazy var wrappedView: View = {
        if let nib = View.nib {
            return nib.instantiate(withOwner: nil, options: nil).first as! View
        } else {
            return View()
        }
    }()

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize(contentView: contentView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.translatesAutoresizingMaskIntoConstraints = false
        initialize(contentView: contentView)
    }
    
    private func initialize(contentView: UIView) {
        wrappedView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        [contentView.leftAnchor.constraint(equalTo: leftAnchor, constant: 0),
         contentView.rightAnchor.constraint(equalTo: rightAnchor, constant: 0),
         contentView.topAnchor.constraint(equalTo: topAnchor, constant: 0),
         contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)].forEach { constraint in
            constraint.isActive = true
        }
        
        contentView.addSubview(wrappedView)
        [wrappedView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
         wrappedView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
         wrappedView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
         wrappedView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)].forEach { constraint in
            constraint.isActive = true
        }
    }
    
}
