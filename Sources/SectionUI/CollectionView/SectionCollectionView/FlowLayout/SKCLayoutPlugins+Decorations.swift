//
//  File.swift
//
//
//  Created by linhey on 2023/10/13.
//

import UIKit
import SectionKit

public protocol SKCLayoutDecorationPlugin: AnyObject {
    associatedtype View: SKCLayoutPlugins.DecorationView
    typealias ActionBlock = (_ context: SKCLayoutPlugins.DecorationActionContext<View>) -> Void
    var from: SKCLayoutPlugins.DecorationItem { get }
    var to: SKCLayoutPlugins.DecorationItem?  { get }
    var viewType: View.Type { get }
    var insets: UIEdgeInsets { get }
    var zIndex: Int { get }
    var actions: [SKCSupplementaryActionType: [ActionBlock]] { get set }
}

public extension SKCLayoutDecorationPlugin {
    
    func apply(to layout: UICollectionViewFlowLayout) {
        if let nib = viewType.nib {
            layout.register(nib, forDecorationViewOfKind: viewType.identifier)
        } else {
            layout.register(viewType.self, forDecorationViewOfKind: viewType.identifier)
        }
    }
    
    @discardableResult
    func onAction(_ kind: SKCSupplementaryActionType, block: @escaping ActionBlock) -> Self {
        if actions[kind] == nil {
            actions[kind] = []
        }
        actions[kind]?.append(block)
        return self
    }
    
    func apply(kind: SKCSupplementaryActionType,
               identifier: String,
               at indexPath: IndexPath,
               view: UICollectionReusableView) {
        guard from.index.wrappedValue == indexPath.section,
              viewType.identifier == identifier,
              let actions = actions[kind],
              !actions.isEmpty,
              let view = view as? View else {
            return
        }
        let context = SKCLayoutPlugins.DecorationActionContext(type: kind,
                                                               kind: .init(rawValue: identifier),
                                                               indexPath: indexPath,
                                                               view: view)
        
        for action in actions {
            action(context)
        }
    }
    
}

public extension SKCLayoutPlugins {
    
    typealias DecorationView = UICollectionReusableView & SKLoadViewProtocol
    
    struct DecorationActionContext<View: DecorationView> {
        public let type: SKCSupplementaryActionType
        public let kind: SKSupplementaryKind
        public let indexPath: IndexPath
        public let view: View
    }
    
    enum DecorationLayout {
        case header
        case cells
        case footer
    }
    
    enum DecorationMode {
        /// 按照可视视图区域计算
        case visibleView
        /// 按照原始的 section 区域计算
        case section
        /// 没有头尾时用sectioninset填充
        case useSectionInsetWhenNotExist(_ layout: [DecorationLayout] = [.header, .footer])
        
    }
    
    struct DecorationItem {
        
        public let index: BindingKey<Int>
        public let layout: [DecorationLayout]
        public let modes: [DecorationMode]
        
        public init(index: BindingKey<Int>,
                    modes: [DecorationMode] = [.visibleView],
                    layout: [DecorationLayout] = [.header, .cells, .footer]) {
            self.index  = index
            self.modes  = modes
            self.layout = layout
            
#if DEBUG
            var useSectionInsetWhenNotExist = false
            var visibleViewOrSection = false
            self.modes.forEach({ mode in
                switch mode {
                case .visibleView, .section:
                    visibleViewOrSection = true
                case .useSectionInsetWhenNotExist:
                    useSectionInsetWhenNotExist = true
                }
            })
            
            if useSectionInsetWhenNotExist, visibleViewOrSection == false {
                assertionFailure("需要指定 .visibleView 或者 .section")
            }
#endif
        }
        
        public init(_ section: SKCSectionProtocol,
                    modes: [DecorationMode] = [.visibleView],
                    layout: [DecorationLayout] = [.header, .cells, .footer]) {
            self.init(index: .init(section), modes: modes, layout: layout)
        }
    }
    
    struct AnyDecoration {
        
        let wrapperValue: any SKCLayoutDecorationPlugin
        
        public init<View: DecorationView>(_ section: SKCSectionActionProtocol,
                                          viewType: View.Type,
                                          zIndex: Int = -1,
                                          layout: [SKCollectionFlowLayout.DecorationLayout] = [.header, .cells, .footer],
                                          insets: UIEdgeInsets = .zero) {
            self.init(sectionIndex: .init(section),
                      viewType: viewType,
                      zIndex: zIndex,
                      layout: layout,
                      insets: insets)
        }
        
        public init<View: DecorationView>(section: SKCSectionProtocol,
                                          viewType: View.Type,
                                          mode: [DecorationMode] = [.visibleView],
                                          zIndex: Int = -1,
                                          layout: [DecorationLayout] = [.header, .cells, .footer],
                                          insets: UIEdgeInsets = .zero) {
            wrapperValue = Decoration<View>(from: .init(index: .init(section), modes: mode, layout: layout),
                                            to: nil,
                                            insets: insets,
                                            zIndex: zIndex)
        }
        
        public init<View: DecorationView>(sectionIndex: BindingKey<Int>,
                                          viewType: View.Type,
                                          modes: [DecorationMode] = [.visibleView],
                                          zIndex: Int = -1,
                                          layout: [DecorationLayout] = [.header, .cells, .footer],
                                          insets: UIEdgeInsets = .zero) {
            wrapperValue = Decoration<View>(from: .init(index: sectionIndex, modes: modes, layout: layout),
                                            to: nil,
                                            insets: insets,
                                            zIndex: zIndex)
        }
        
        public init<View: DecorationView>(from: DecorationItem, to: DecorationItem?,
                                          viewType: View.Type,
                                          zIndex: Int = -1,
                                          insets: UIEdgeInsets = .zero) {
            wrapperValue = Decoration<View>(from: from,
                                            to: to,
                                            insets: insets,
                                            zIndex: zIndex)
        }
    }
    
    class Decoration<View: DecorationView>: SKCLayoutDecorationPlugin {
        
        public let from: DecorationItem
        public let to: DecorationItem?
        public let viewType: View.Type
        public let insets: UIEdgeInsets
        public let zIndex: Int
        public var actions: [SKCSupplementaryActionType : [ActionBlock]] = [:]
        
        public init(from: DecorationItem, to: DecorationItem?,
                    insets: UIEdgeInsets,
                    zIndex: Int,
                    actions: [SKCSupplementaryActionType : [ActionBlock]] = [:]) {
            self.from = from
            self.to = to
            self.viewType = View.self
            self.insets = insets
            self.zIndex = zIndex
            self.actions = actions
        }
    }
    
    class BindingKey<Value> {
        
        private let closure: () -> Value?
        public var wrappedValue: Value? { closure() }
        
        public init(get closure: @escaping () -> Value?) {
            self.closure = closure
        }
        
    }
    
    struct Decorations: SKCLayoutPlugin {
        
        let layoutWeakBox: SKWeakBox<SKCollectionFlowLayout>
        let decorations: [any SKCLayoutDecorationPlugin]
        let fixSupplementaryViewInset: SKCLayoutPlugins.FixSupplementaryViewInset?
        
        init(layout: SKCollectionFlowLayout,
             decorations: [any SKCLayoutDecorationPlugin],
             fixSupplementaryViewInset: SKCLayoutPlugins.FixSupplementaryViewInset?) {
            self.layoutWeakBox = .init(layout)
            self.decorations = decorations
            self.fixSupplementaryViewInset = fixSupplementaryViewInset
            decorations.forEach { decoration in
                decoration.apply(to: layout)
            }
        }
        
        func observe(kind: SKCSupplementaryActionType,
                     identifier: String,
                     at indexPath: IndexPath,
                     view: UICollectionReusableView) {
            decorations.forEach { decoration in
                decoration.apply(kind: kind, identifier: identifier, at: indexPath, view: view)
            }
        }
        
        func run(with attributes: [UICollectionViewLayoutAttributes]) -> [UICollectionViewLayoutAttributes]? {
            var dict = [Int: [Int: [any SKCLayoutDecorationPlugin]]](minimumCapacity: decorations.count)
            decorations.forEach { item in
                if let value = item.from.index.wrappedValue {
                    if dict[value] == nil {
                        dict[value] = [:]
                    }
                    
                    if dict[value]?[item.zIndex] == nil {
                        dict[value]?[item.zIndex] = [item]
                    } else {
                        dict[value]?[item.zIndex]?.append(item)
                    }
                }
            }
            
            var all: [Int: [any SKCLayoutDecorationPlugin]]?
            if let wrappedValue = BindingKey<Int>.all.wrappedValue {
                all = dict[wrappedValue]
            }
            
            var set = Set<Int>()
            let sections = attributes
                .map(\.indexPath.section)
                .filter { set.insert($0).inserted }
                .map { index -> [UICollectionViewLayoutAttributes] in
                    guard let decorations = dict[index] ?? all else {
                        return [UICollectionViewLayoutAttributes]()
                    }
                    return decorations
                        .sorted(by: { $0.key < $1.key })
                        .compactMap { (zIndex: Int, list: [any SKCLayoutDecorationPlugin]) in
                            list.enumerated().compactMap { (offset, decoration) in
                                task(section: index, index: offset, decoration: decoration)
                            }
                        }.flatMap({ $0 })
                }.flatMap { $0 }
            
            return attributes + sections
            
        }
        
        func frame(for item: DecorationItem, at section: IndexPath) -> CGRect? {
            guard let layout else { return nil }
            
            var supplementaryMode: DecorationMode?
            var sectionInsetPaddingWhenLayout: [DecorationLayout] = []
            
            for mode in item.modes {
                switch mode {
                case .section, .visibleView:
                    supplementaryMode = mode
                case .useSectionInsetWhenNotExist(let layout):
                    sectionInsetPaddingWhenLayout = layout
                }
            }
            
            func supplementary(of key: String) -> UICollectionViewLayoutAttributes? {
                guard let supplementaryMode = supplementaryMode else { return nil }
                switch supplementaryMode {
                case .section:
                    return layout.attributes(of: key, at: section, useCache: false)
                case .visibleView:
                    return layout.attributes(of: key, at: section, useCache: true)
                case .useSectionInsetWhenNotExist:
                    return nil
                }
            }
            
            func inset(_ layout: DecorationLayout) -> CGFloat {
                guard !sectionInsetPaddingWhenLayout.isEmpty else { return 0 }
                let insets = insetForSection(at: section.section)
                switch layout {
                case .header:
                    return insets.top
                case .cells:
                    return 0
                case .footer:
                    return insets.bottom
                }
            }
            
            var frames = [CGRect]()
            var unions = [DecorationLayout]()
            
            if item.layout.contains(.header),
               let attributes = supplementary(of: UICollectionView.elementKindSectionHeader),
               attributes.frame.width > 0,
               attributes.frame.height > 0 {
                frames.append(attributes.frame)
                unions.append(.header)
            }
            
            if item.layout.contains(.footer),
               let attributes = supplementary(of: UICollectionView.elementKindSectionFooter),
               attributes.frame.width > 0,
               attributes.frame.height > 0 {
                frames.append(attributes.frame)
                unions.append(.footer)
            }
            
            if item.layout.contains(.cells) {
                let cells = (0 ..< collectionView.numberOfItems(inSection: section.section)).compactMap {
                    layout.layoutAttributesForItem(at: IndexPath(row: $0, section: section.section))?.frame
                }
                if let frame = CGRect.union(cells) {
                    frames.append(frame)
                    unions.append(.cells)
                }
            }
            
            guard var frame = CGRect.union(frames) else {
                return nil
            }
            
            if !unions.contains(.header), sectionInsetPaddingWhenLayout.contains(.header) {
                let inset = inset(.header)
                frame.origin.y -= inset
                frame.size.height += inset
            }
            
            if !unions.contains(.footer), sectionInsetPaddingWhenLayout.contains(.footer) {
                let inset = inset(.footer)
                frame.size.height += inset
            }
            
            return frame
        }
        
        func task(section: Int, index: Int, decoration: any SKCLayoutDecorationPlugin) -> UICollectionViewLayoutAttributes? {
            let sectionIndexPath = IndexPath(item: index, section: section)
            var frames = [CGRect]()
            
            if let frame = frame(for: decoration.from, at: sectionIndexPath) {
                frames.append(frame)
            }
            
            if let to = decoration.to,
               let section = to.index.wrappedValue,
               let frame = frame(for: to, at: IndexPath(item: index, section: section)) {
                frames.append(frame)
            }
            
            guard let frame = CGRect.union(frames)?.apply(insets: decoration.insets) else {
                return nil
            }
            
            let attribute = UICollectionViewLayoutAttributes(forDecorationViewOfKind: decoration.viewType.identifier, with: sectionIndexPath)
            attribute.zIndex = decoration.zIndex
            attribute.frame = frame
            return attribute
        }
        
    }
    
}

public extension SKCLayoutPlugins.BindingKey {
    static func constant(_ value: Value) -> SKCollectionFlowLayout.BindingKey<Value> {
        .init(get: { value })
    }
}

public extension SKCLayoutPlugins.BindingKey where Value == Int {
    static let all = SKCollectionFlowLayout.BindingKey.constant(-1)
}

extension SKCLayoutPlugins.BindingKey: Equatable where Value: Equatable {
    public static func == (lhs: SKCollectionFlowLayout.BindingKey<Value>, rhs: SKCollectionFlowLayout.BindingKey<Value>) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }
}

extension SKCLayoutPlugins.BindingKey: Hashable where Value: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(closure())
    }
}
