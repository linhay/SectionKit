//
//  File.swift
//  
//
//  Created by linhey on 2022/10/5.
//

import UIKit

open class SKWrapperView<Content: UIView>: UIView, SKLoadViewProtocol, SKConfigurableView {

    public struct Model {
        public let insets: UIEdgeInsets
        public let height: CGFloat
        public let style: (_ view: Content) -> Void
        public init(insets: UIEdgeInsets,
                    height: CGFloat,
                    style: @escaping (Content) -> Void) {
            self.insets = insets
            self.height = height
            self.style = style
        }
    }
    
    public static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        guard let model else { return .zero }
        return .init(width: size.width, height: model.height + model.insets.top + model.insets.bottom)
    }
        
    public func config(_ model: Model) {
        model.style(content)
        left.constant = model.insets.left
        right.constant = model.insets.right
        top.constant = model.insets.top
        bottom.constant = model.insets.bottom
        height.constant = model.height
    }
    
    private lazy var content = Content()
    private lazy var left   = content.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
    private lazy var right  = content.rightAnchor.constraint(equalTo: rightAnchor, constant: 0)
    private lazy var top    = content.topAnchor.constraint(equalTo: topAnchor, constant: 0)
    private lazy var bottom = content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
    private lazy var height = content.heightAnchor.constraint(equalToConstant: 0)

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        left.isActive = true
        right.isActive = true
        top.isActive = true
        bottom.isActive = true
        height.isActive = true
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}
