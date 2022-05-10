//
//  SingleTypeHorizontalSection.swift
//  Passionate
//
//  Created by linhey on 2022/3/25.
//

#if canImport(UIKit)
import UIKit

public extension SectionCollectionDriveProtocol {
    func horizontalWrapper(height: CGFloat,
                           insets: UIEdgeInsets = .zero,
                           style: ((SectionCollectionView) -> Void)? = nil) -> SectionHorizontalWrapper<Self>
    {
        .init(.init(section: self, height: height, insets: insets, style: style))
    }
}

public final class SectionHorizontalWrapper<Section: SectionCollectionDriveProtocol>: SectionCollectionProtocol, SectionCollectionFlowLayoutSafeSizeProtocol, SectionWrapperProtocol {
    public var sectionState: SectionState?
    public var itemCount: Int = 1
    
    public lazy var safeSize: SectionSafeSize = defaultSafeSize
    let model: SectionHorizontalCell<Section>.Model
    public var wrappedSection: Section { model.section }
    private var containerStyle: ((SectionHorizontalCell<Section>, Int) -> Void)?
    
    public func apply(containerStyle: ((SectionHorizontalCell<Section>, Int) -> Void)?) -> Self {
        self.containerStyle = containerStyle
        return self
    }
    
    public init(_ model: SectionHorizontalCell<Section>.Model) {
        self.model = model
    }
    
    public func item(at row: Int) -> UICollectionViewCell {
        let cell = dequeue(at: row) as SectionHorizontalCell<Section>
        cell.config(model)
        containerStyle?(cell, row)
        return cell
    }
    
    public func itemSize(at _: Int) -> CGSize {
        SectionHorizontalCell<Section>.preferredSize(limit: safeSize.size(self), model: model)
    }
    
    public func config(sectionView _: UICollectionView) {
        register(SectionHorizontalCell<Section>.self)
    }
}

public final class SectionHorizontalCell<Section: SectionCollectionDriveProtocol>: UICollectionViewCell, SectionConfigurableView, SectionLoadViewProtocol {
    public static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        guard let model = model else { return .zero }
        return CGSize(width: size.width, height: model.height + model.insets.top + model.insets.bottom)
    }
    
    public func config(_ model: Model) {
        model.style?(sectionView)
        edgeConstraint.apply(model.insets)
        sectionView.manager.update(model.section)
    }
    
    public struct Model {
        public let section: Section
        public let height: CGFloat
        public let insets: UIEdgeInsets
        public let style: ((SectionCollectionView) -> Void)?
        
        public init(section: Section,
                    height: CGFloat,
                    insets: UIEdgeInsets = .zero,
                    style: ((SectionCollectionView) -> Void)? = nil)
        {
            self.section = section
            self.height = height
            self.insets = insets
            self.style = style
        }
    }
    
    private struct EdgeConstraint {
        var all: [NSLayoutConstraint] { [top, left, right, bottom] }
        
        let top: NSLayoutConstraint
        let left: NSLayoutConstraint
        let right: NSLayoutConstraint
        let bottom: NSLayoutConstraint
        
        init(_ view: UIView, superView: UIView) {
            top = view.topAnchor.constraint(equalTo: superView.topAnchor, constant: 0)
            left = view.leftAnchor.constraint(equalTo: superView.leftAnchor, constant: 0)
            right = view.rightAnchor.constraint(equalTo: superView.rightAnchor, constant: 0)
            bottom = view.bottomAnchor.constraint(equalTo: superView.bottomAnchor, constant: 0)
        }
        
        func apply(_ inset: UIEdgeInsets) {
            top.constant = inset.top
            left.constant = inset.left
            right.constant = -inset.right
            bottom.constant = -inset.bottom
        }
        
        func activate() {
            NSLayoutConstraint.activate(all)
        }
        
        func deactivate() {
            NSLayoutConstraint.deactivate(all)
        }
    }
    
    private lazy var sectionView = SectionCollectionView()
    private lazy var edgeConstraint = EdgeConstraint(sectionView, superView: contentView)
    
    override init(frame _: CGRect) {
        super.init(frame: .zero)
        initialize()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    private func initialize() {
        translatesAutoresizingMaskIntoConstraints = false
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        sectionView.backgroundColor = .clear
        contentView.addSubview(sectionView)
        sectionView.scrollDirection = .horizontal
        edgeConstraint.activate()
    }
}
#endif
