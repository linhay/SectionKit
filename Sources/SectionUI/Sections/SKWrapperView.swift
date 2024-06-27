//
//  File.swift
//
//
//  Created by linhey on 2022/10/5.
//

#if canImport(UIKit)
import UIKit


public extension SKSectionWrapper where Base: UIView {
    
    static func wrapperToConfigurableView() -> SKWrapperView<Base, Void>.Type {
        return wrapperToConfigurableView(userInfo: Void.self)
    }
    
    static func wrapperToConfigurableView<UserInfo>(userInfo: UserInfo.Type) -> SKWrapperView<Base, UserInfo>.Type {
        return SKWrapperView<Base, UserInfo>.self
    }
    
}


open class SKWrapperView<Content: UIView, UserInfo>: UIView, SKLoadViewProtocol, SKConfigurableView {
    
    public struct Model {
        
        public let userInfo: UserInfo
        public let insets: UIEdgeInsets
        public let size: (_ limit: CGSize) -> CGSize
        public let style: (_ view: Content) -> Void
        
        public init(userInfo: UserInfo, insets: UIEdgeInsets, size: @escaping (_ limit: CGSize) -> CGSize, style: @escaping (Content) -> Void) {
            self.userInfo = userInfo
            self.insets = insets
            self.size = size
            self.style = style
        }
        
        public init(userInfo: UserInfo, insets: UIEdgeInsets) where Content: SKConfigurableView, UserInfo == Content.Model {
            self.userInfo = userInfo
            self.insets = insets
            self.size = { limit in
                var size = Content.preferredSize(limit: .init(width: limit.width - insets.left - insets.right,
                                                              height: limit.height - insets.top - insets.bottom),
                                                 model: userInfo)
                size.width += insets.left + insets.right
                size.height += insets.top + insets.bottom
                return size
            }
            self.style = { view in
                view.config(userInfo)
            }
        }
        
        public init(insets: UIEdgeInsets,
                    size: @escaping (_ limit: CGSize) -> CGSize,
                    style: @escaping (Content) -> Void) where UserInfo == Void {
            self.init(userInfo: (), insets: insets, size: size, style: style)
        }
    }
    
    public static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        guard let model else { return .zero }
        return model.size(size)
    }
    
    public func config(_ model: Model) {
        model.style(content)
        left.constant   = model.insets.left
        right.constant  = -model.insets.right
        top.constant    = model.insets.top
        bottom.constant = -model.insets.bottom
    }
    
    private lazy var content = Content()
    private lazy var left   = content.leftAnchor.constraint(equalTo: leftAnchor, constant: 0)
    private lazy var right  = content.rightAnchor.constraint(equalTo: rightAnchor, constant: 0)
    private lazy var top    = content.topAnchor.constraint(equalTo: topAnchor, constant: 0)
    private lazy var bottom = content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(content)
        content.translatesAutoresizingMaskIntoConstraints = false
        left.isActive = true
        right.isActive = true
        top.isActive = true
        bottom.isActive = true
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
}

#endif
