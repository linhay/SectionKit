//
//  File.swift
//
//
//  Created by linhey on 2023/10/12.
//

import UIKit

public struct SKCLayoutPlugins {
    
    /// 布局插件样式
    public enum Mode: Equatable {
        /// 左对齐
        case left([SKBindingKey<Int>])
        /// 居中对齐
        case centerX([SKBindingKey<Int>])
        /// fix: header & footer 贴合 cell
        case fixSupplementaryViewInset(FixSupplementaryViewInset.Direction)
        /// fix: header & footer size 与设定值不符
        case fixSupplementaryViewSize
        /// fix: header & footer 调整尺寸, 调整前会重置为真实设定尺寸
        case adjustSupplementaryViewSize(FixSupplementaryViewSize.Condition)
        /// section 装饰视图
        case decorations([any SKCLayoutDecorationPlugin])
        
        var priority: Int {
            switch self {
            case .left:    return 100
            case .centerX: return 100
            case .fixSupplementaryViewSize:    return 1
            case .fixSupplementaryViewInset:   return 2
            case .adjustSupplementaryViewSize: return 3
            case .decorations: return 200
            }
        }
        
        public static func == (lhs: SKCLayoutPlugins.Mode, rhs: SKCLayoutPlugins.Mode) -> Bool {
            lhs.priority == rhs.priority
        }
    }
    
    public var modes: [Mode] = [] {
        didSet {
            let modes = sort(modes: modes)
            guard modes != self.modes else {
                return
            }
            self.modes = modes
        }
    }
    
    public init(modes: [Mode]) {
        self.modes = sort(modes: modes)
    }
    
    func sort(modes: [Mode]) -> [Mode] {
        var set = Set<Int>()
        var newModes = [Mode]()
        
        var lefts = [SKBindingKey<Int>]()
        var centerXs = [SKBindingKey<Int>]()
        var decorations = [any SKCLayoutDecorationPlugin]()

        /// 优先级冲突去重
        for mode in modes {
            switch mode {
            case .fixSupplementaryViewInset,
                    .fixSupplementaryViewSize,
                    .adjustSupplementaryViewSize:
                if set.insert(mode.priority).inserted {
                    newModes.append(mode)
                } else {
                    assertionFailure("mode冲突: \(newModes.filter { $0.priority == mode.priority })")
                }
            case .centerX(let array):
                centerXs.append(contentsOf: array)
            case .left(let array):
                lefts.append(contentsOf: array)
            case .decorations(let array):
                decorations.append(contentsOf: array)
            }
        }

        if !lefts.isEmpty {
            newModes.append(.left(lefts))
        }
        
        if !centerXs.isEmpty {
            newModes.append(.centerX(centerXs))
        }
        
        if !decorations.isEmpty {
            newModes.append(.decorations(decorations))
        }
        
        /// mode 重排
        return newModes.sorted(by: { $0.priority < $1.priority })
    }
    
}


public extension SKCLayoutPlugins.Mode {
    
    static var left: SKCLayoutPlugins.Mode { .left([.all]) }
    static var centerX: SKCLayoutPlugins.Mode { .centerX([.all]) }

    static func decorations(_ decoration: [SKCLayoutAnyDecoration]) -> SKCLayoutPlugins.Mode {
        .decorations(decoration.map(\.wrapperValue))
    }
    
    static func decorations(_ decoration: SKCLayoutAnyDecoration) -> SKCLayoutPlugins.Mode {
        .decorations([decoration])
    }
    
    static func decorations<View: SKCDecorationView>(_ decoration: [SKCLayoutDecoration.Entity<View>]) -> SKCLayoutPlugins.Mode {
        .decorations(decoration as [any SKCLayoutDecorationPlugin])
    }
    
    static func decorations<View: SKCDecorationView>(_ decoration: SKCLayoutDecoration.Entity<View>) -> SKCLayoutPlugins.Mode {
        .decorations([decoration])
    }
    
    static func decorations(_ decoration: any SKCLayoutDecorationPlugin) -> SKCLayoutPlugins.Mode {
        .decorations([decoration])
    }
    
}
