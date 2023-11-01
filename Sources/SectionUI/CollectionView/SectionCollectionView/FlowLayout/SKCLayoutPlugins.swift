//
//  File.swift
//
//
//  Created by linhey on 2023/10/12.
//

import UIKit

public struct SKCLayoutPlugins {
    
    /// 布局插件样式
    public enum Mode {
        /// 左对齐
        case left
        /// 居中对齐
        case centerX
        /// fix: header & footer 贴合 cell
        case fixSupplementaryViewInset(FixSupplementaryViewInset.Direction)
        /// fix: header & footer size与设定值不符
        case fixSupplementaryViewSize
        /// 置顶section header view
        case sectionHeadersPinToVisibleBounds([BindingKey<Int>])
        /// section 装饰视图
        case decorations([Decoration])
        
        var priority: Int {
            switch self {
            case .left:    return 100
            case .centerX: return 100
            case .fixSupplementaryViewSize:  return 1
            case .fixSupplementaryViewInset: return 2
            case .decorations: return 200
            case .sectionHeadersPinToVisibleBounds: return 300
            }
        }
    }
    
    public var modes: [Mode] = [] {
        didSet {
            var set = Set<Int>()
            var newModes = [Mode]()
            
            /// 优先级冲突去重
            for item in modes {
                if set.insert(item.priority).inserted {
                    newModes.append(item)
                } else {
                    assertionFailure("mode冲突: \(newModes.filter { $0.priority == item.priority })")
                }
            }
            
            /// mode 重排
            modes = newModes.sorted(by: { $0.priority < $1.priority })
        }
    }
    
    public init(modes: [Mode]) {
        self.modes = modes
    }
    
}
