// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

#if canImport(UIKit)
import UIKit

/// 补充视图注册类型枚举
/// Supplementary view registration type enumeration
///
/// - header: 头部视图 / Header view
/// - footer: 底部视图 / Footer view  
/// - cell: 单元格视图 / Cell view
/// - custom: 自定义视图 / Custom view
public enum SKSupplementaryKind: Equatable, Hashable, RawRepresentable {
    /// 头部补充视图
    /// Header supplementary view
    case header
    
    /// 底部补充视图
    /// Footer supplementary view
    case footer
    
    /// 单元格视图
    /// Cell view
    case cell
    
    /// 自定义补充视图
    /// Custom supplementary view
    case custom(_ value: String)
    
    /// 从原始值初始化
    /// Initialize from raw value
    public init(rawValue: String) {
        switch rawValue {
        case UICollectionView.elementKindSectionHeader: self = .header
        case UICollectionView.elementKindSectionFooter: self = .footer
        case "UICollectionViewCell": self = .cell
        default: self = .custom(rawValue)
        }
    }
    
    /// 获取原始值
    /// Get raw value
    public var rawValue: String {
        switch self {
        case .header: return UICollectionView.elementKindSectionHeader
        case .footer: return UICollectionView.elementKindSectionFooter
        case .cell: return "UICollectionViewCell"
        case let .custom(value): return value
        }
    }
}
#endif