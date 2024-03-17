//
//  File.swift
//
//
//  Created by linhey on 2024/3/15.
//

import UIKit
import SectionKit

public enum SKCSectionLayoutPlugin {
    case decorations([any SKCLayoutDecorationPlugin])
    public var convert: SKCLayoutPlugins.Mode {
        switch self {
        case .decorations(let array):
            return .decorations(array)
        }
    }
    
}

public protocol SKCSectionLayoutPluginProtocol {
    var sectionInjection: SKCSectionInjection? { get set }
    var plugins: [SKCSectionLayoutPlugin] { get }
}

extension SKCSingleTypeSection: SKCSectionLayoutPluginProtocol {
    
    public var plugins: [SKCSectionLayoutPlugin] {
        set { self.environment(of: newValue) }
        get { self.environment(of: [SKCSectionLayoutPlugin].self) ?? [] }
    }
    
    public typealias DecorationViewStyle<View: SKCDecorationView> = ((_ decoration: SKCLayoutDecoration.Entity<View>) -> Void)
    
    public func set<View: SKCDecorationView>(decoration: View.Type,
                                             style: DecorationViewStyle<View>? = nil) -> Self {
        let decoration = SKCLayoutDecoration.Entity<View>(from: .init(self))
        style?(decoration)
        plugins.append(.decorations([decoration]))
        return self
    }
    
    public func set<View: SKCDecorationView & SKConfigurableModelProtocol>(decoration: View.Type,
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
