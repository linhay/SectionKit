//
//  SectionUnitViewWrapper.swift
//  DUI
//
//  Created by linhey on 2022/9/20.
//

import UIKit

public extension SKConfigurableView where Self: SKLoadViewProtocol {
    
    static func eraseToCollectionCell() -> SKCEraseCell<Self>.Type {
        return SKCEraseCell<Self>.self
    }
    
}

public extension SKConfigurableView where Self: SKLoadViewProtocol {
    
    static func eraseToCollectionReusableView() -> SKCEraseReusableView<Self>.Type {
        return SKCEraseReusableView<Self>.self
    }
    
}

public class SKCEraseCell<View: SKConfigurableView & SKLoadViewProtocol>: UICollectionViewCell, SKConfigurableView, SKLoadViewProtocol {
    
    public static func preferredSize(limit size: CGSize, model: View.Model?) -> CGSize {
        View.preferredSize(limit: size, model: model)
    }
    
    public typealias Model = View.Model
    
    
    public func config(_ model: View.Model) {
        eraseView.config(model)
    }
    
    private lazy var eraseView = View()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize(contentView: contentView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.translatesAutoresizingMaskIntoConstraints = false
        initialize(contentView: contentView)
    }
    
    private func initialize(contentView: UIView) {
        eraseView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(eraseView)
        [eraseView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
         eraseView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
         eraseView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
         eraseView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)].forEach { constraint in
            constraint.priority = .defaultHigh
            constraint.isActive = true
        }
    }
    
}


public class SKCEraseReusableView<View: SKConfigurableView & SKLoadViewProtocol>: UICollectionReusableView, SKConfigurableView, SKLoadViewProtocol {
    
    public static func preferredSize(limit size: CGSize, model: View.Model?) -> CGSize {
        View.preferredSize(limit: size, model: model)
    }
    
    public typealias Model = View.Model
    
    
    public func config(_ model: View.Model) {
        eraseView.config(model)
    }
    
    private lazy var eraseView = View()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        initialize(contentView: self)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize(contentView: self)
    }
    
    private func initialize(contentView: UIView) {
        contentView.translatesAutoresizingMaskIntoConstraints = false
        eraseView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(eraseView)
        [eraseView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
         eraseView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
         eraseView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
         eraseView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)].forEach { constraint in
            constraint.priority = .defaultHigh
            constraint.isActive = true
        }
    }
    
}

