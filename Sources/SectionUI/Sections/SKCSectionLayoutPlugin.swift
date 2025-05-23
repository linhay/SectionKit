//
//  File.swift
//
//
//  Created by linhey on 2024/3/15.
//

import UIKit
import SectionKit
import Combine

public enum SKCSectionLayoutPluginAlias {
    
    case left
    case centerX
    case right
    
    public var convert: SKCSectionLayoutPlugin {
        switch self {
        case .left:
            return SKCSectionLayoutPlugin.verticalAlignment(.left)
        case .centerX:
            return SKCSectionLayoutPlugin.verticalAlignment(.center)
        case .right:
            return SKCSectionLayoutPlugin.verticalAlignment(.right)
        }
        
    }
}

/// 枚举，表示不同的节布局插件。
public enum SKCSectionLayoutPlugin {
    case pin(SKCSectionPin)
    case permanentAttributes(SKCLayoutPlugins.FetchAttributes)
    case attributes([SKCPluginAdjustAttributes])
    case decorations([any SKCLayoutDecorationPlugin])
    case verticalAlignment(SKCLayoutPlugins.VerticalAlignment)
    case horizontalAlignment(SKCLayoutPlugins.HorizontalAlignment)

    /// 将节布局插件转换为对应的布局插件模式。
    ///
    /// - Parameter section: 需要转换的节。
    /// - Returns: 对应的布局插件模式。
    public func convert(_ section: SKCSectionActionProtocol) -> SKCLayoutPlugins.Mode? {
        switch self {
        case .pin:
            return nil
        case .permanentAttributes(let array):
            return .permanentAttributes(array)
        case .decorations(let array):
            return .decorations(array)
        case .attributes(let array):
            return .attributes(array)
        case .verticalAlignment(let payload):
            return .verticalAlignment([.init(alignment: payload, sections: [.init(section)])])
        case .horizontalAlignment(let payload):
            return .horizontalAlignment([.init(alignment: payload, sections: [.init(section)])])
        }
    }
    
}

/// 协议，表示节布局插件协议。
public protocol SKCSectionLayoutPluginProtocol: AnyObject {
    var sectionInjection: SKCSectionInjection? { get set }
    var plugins: [SKCSectionLayoutPlugin] { get set }
}

extension SKCSingleTypeSection: SKCSectionLayoutPluginProtocol {
    
    public var plugins: [SKCSectionLayoutPlugin] {
        set { self.environment(of: newValue) }
        get { self.environment(of: [SKCSectionLayoutPlugin].self) ?? [] }
    }
    
}

public extension SKCSectionLayoutPluginProtocol {
    
    /// 添加多个布局插件。
    ///
    /// - Parameter value: 布局插件数组。
    /// - Returns: 更新后的对象。
    @discardableResult
    func addLayoutPlugins(_ value: SKCSectionLayoutPluginAlias...) -> Self {
        return addLayoutPlugins(value)
    }
    
    /// 添加单个布局插件。
    ///
    /// - Parameter value: 布局插件。
    /// - Returns: 更新后的对象。
    @discardableResult
    func addLayoutPlugins(_ value: SKCSectionLayoutPluginAlias) -> Self {
        return addLayoutPlugins([value])
    }
    
    /// 添加布局插件数组。
    ///
    /// - Parameter value: 布局插件数组。
    /// - Returns: 更新后的对象。
    @discardableResult
    func addLayoutPlugins(_ value: [SKCSectionLayoutPluginAlias]) -> Self {
        plugins.append(contentsOf: value.map(\.convert))
        return self
    }
    
}

public extension SKCSectionLayoutPluginProtocol {
    
    /// 添加多个布局插件。
    ///
    /// - Parameter value: 布局插件数组。
    /// - Returns: 更新后的对象。
    @discardableResult
    func addLayoutPlugins(_ value: SKCSectionLayoutPlugin...) -> Self {
        return addLayoutPlugins(value)
    }
    
    /// 添加单个布局插件。
    ///
    /// - Parameter value: 布局插件。
    /// - Returns: 更新后的对象。
    @discardableResult
    func addLayoutPlugins(_ value: SKCSectionLayoutPlugin) -> Self {
        return addLayoutPlugins([value])
    }
    
    /// 添加布局插件数组。
    ///
    /// - Parameter value: 布局插件数组。
    /// - Returns: 更新后的对象。
    @discardableResult
    func addLayoutPlugins(_ value: [SKCSectionLayoutPlugin]) -> Self {
        plugins.append(contentsOf: value)
        return self
    }
    
}

public extension SKCSectionLayoutPluginProtocol where Self: SKCSectionProtocol {

    /// 设置属性调整构建器。
    ///
    /// - Parameter builder: 属性调整构建器闭包。
    /// - Returns: 更新后的对象。
    @discardableResult
    func setAttributes(_ builder: SKCPluginAdjustAttributes.Style) -> Self {
        return self.addLayoutPlugins(.attributes([SKCPluginAdjustAttributes(section: .init(self), builder)]))
    }
    
    /// 设置属性调整构建器，当条件满足时应用。
    ///
    /// - Parameters:
    ///   - when: 条件闭包，当返回 true 时应用 builder。
    ///   - builder: 属性调整构建器闭包。
    /// - Returns: 更新后的对象。
    @discardableResult
    func setAttributes(when: SKWhen<SKCPluginAdjustAttributes.Context>,
                       style: SKCPluginAdjustAttributes.Style) -> Self {
        return self.setAttributes(.init({ object in
            guard when.isIncluded(object) else { return object }
            return style.build(object)
        }))
    }
    
}

public extension SKCSectionLayoutPluginProtocol where Self: SKCSectionProtocol {
    
    typealias DecorationViewStyle<View: SKCDecorationView> = ((_ decoration: SKCLayoutDecoration.Entity<View>) -> Void)
    
    /// 设置装饰视图样式。
    ///
    /// - Parameters:
    ///   - decoration: 装饰视图类型。
    ///   - style: 可选的装饰视图样式闭包。
    /// - Returns: 更新后的对象。
    @discardableResult
    func set<View: SKCDecorationView>(decoration: View.Type,
                                      style: DecorationViewStyle<View>? = nil) -> Self {
        let decoration = SKCLayoutDecoration.Entity<View>(from: .init(self))
        style?(decoration)
        plugins = plugins.compactMap { plugin in
            switch plugin {
            case .decorations(var list):
                list = list.filter({ $0.id != decoration.id })
                if !list.isEmpty {
                    return .decorations(list)
                } else {
                    return nil
                }
            default:
                return plugin
            }
        }
        return self.addLayoutPlugins(.decorations([decoration]))
    }
    
    /// 设置带模型的装饰视图样式。
    ///
    /// - Parameters:
    ///   - decoration: 装饰视图类型。
    ///   - model: 装饰视图模型。
    ///   - style: 可选的装饰视图样式闭包。
    /// - Returns: 更新后的对象。
    @discardableResult
    func set<View: SKCDecorationView & SKConfigurableModelProtocol>(decoration: View.Type,
                                                                    model: View.Model,
                                                                    style: DecorationViewStyle<View>? = nil) -> Self {
        return set(decoration: decoration) { decoration in
            decoration.onAction(.willDisplay) { context in
                context.view.config(model)
            }
            style?(decoration)
        }
    }
    
}

public class SKCSectionPin: Cancellable {
    
    public weak var sectionView: UICollectionView?
    let id = UUID().uuidString
    var frame: CGRect?
    let when: SKWhen<SKCPluginAdjustAttributes.Context>
    var contentOffset: CGPoint = .zero
    var attributes: UICollectionViewLayoutAttributes?
     var cancellables = Set<AnyCancellable>()
    
    lazy var sroll: SKScrollViewDelegateHandler = {
        let item = SKScrollViewDelegateHandler()
        item.id = id
        contentOffset = sectionView?.contentOffset ?? .zero
        item.onChanged { [weak self] scrollView in
            guard let self = self else { return }
            contentOffset = sectionView?.contentOffset ?? .zero
            sectionView?.collectionViewLayout.invalidateLayout()
        }
        return item
    }()
    
    lazy var style = SKCPluginAdjustAttributes.Style { [weak self] object in
        guard let self = self else { return object }
        if frame == nil {
            frame = object.attributes.frame
        }
        attributes = object.attributes
        self.refresh(attributes: object.attributes)
        return object
    }
    
    func refresh(attributes: UICollectionViewLayoutAttributes) {
        let frame = frame ?? attributes.frame
        attributes.frame.origin.y = max(contentOffset.y, frame.origin.y)
    }
    
    var deinitHook: (_ id: String) -> Void
    
    public init(when: SKWhen<SKCPluginAdjustAttributes.Context>, deinit: @escaping (_ id: String) -> Void) {
        self.when = when
        self.deinitHook = `deinit`
    }
    
    public func cancel() {
        deinitHook(id)
        cancellables.removeAll()
    }
    
    deinit {
        deinitHook(id)
    }
}

public extension SKCSectionLayoutPluginProtocol where Self: SKCSectionProtocol {

    @discardableResult
    func pin(header manager: SKCManager) -> AnyCancellable {
        pin(when: .init({ object in
            return object.plugin.kind(of: object.attributes) == .header
        }), manager: manager)
    }
    
    @discardableResult
    func pin(footer manager: SKCManager) -> AnyCancellable {
        pin(when: .init({ object in
            return object.plugin.kind(of: object.attributes) == .footer
        }), manager: manager)
    }
    
    @discardableResult
    func pin(cell row: Int, manager: SKCManager) -> AnyCancellable {
        pin(when: .equal(\.attributes.indexPath.row, row)
            .and(.equal(\.attributes.representedElementCategory, .cell)),
            manager: manager)
    }
    
    @discardableResult
    func pin(when: SKWhen<SKCPluginAdjustAttributes.Context>, manager: SKCManager) -> AnyCancellable {
        let model = SKCSectionPin(when: when) { [weak self] id in
            guard let self = self else { return }
            self.sectionInjection?.manager?.scrollObserver.remove(id: id)
            self.plugins = self.plugins.filter { plugin in
                switch plugin {
                case .pin(let model):
                    return model.id != id
                case .permanentAttributes(let list):
                    return list.id != id
                default:
                    return true
                }
            }
        }
        self.setAttributes(when: .init({ [weak self] object in
            guard let self = self else { return false }
            return object.attributes.indexPath.section == self.sectionIndex
        }).and(when), style: model.style)
        
        self.addLayoutPlugins(.pin(model))
        self.addLayoutPlugins(.permanentAttributes(.init(id: model.id, fetch: { [weak model] in
            guard let model = model else { return nil }
            return model.attributes
        })))
        model.sectionView = manager.sectionView
        manager.scrollObserver.add(scroll: model.sroll)
        return .init(model)
    }
    
}
