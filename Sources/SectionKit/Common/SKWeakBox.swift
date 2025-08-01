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

/// 弱引用盒子，用于持有对象的弱引用，支持动态成员查找
/// Weak reference box for holding weak references to objects with dynamic member lookup support
@dynamicMemberLookup
public final class SKWeakBox<Value: AnyObject>: Equatable, Hashable {
   
    /// 弱引用的值
    /// Weakly referenced value
    public weak var value: Value?
    
    /// 初始化弱引用盒子
    /// Initialize weak reference box
    public init(_ value: Value?) {
        self.value = value
    }
    
    /// 动态成员查找，支持可写键路径
    /// Dynamic member lookup supporting writable key paths
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<Value, T?>) -> T? {
        get { value?[keyPath: keyPath] }
        set { value?[keyPath: keyPath] = newValue }
    }
    
    /// 动态成员查找，支持引用可写键路径
    /// Dynamic member lookup supporting reference writable key paths
    public subscript<T>(dynamicMember keyPath: ReferenceWritableKeyPath<Value, T?>) -> T? {
        get { value?[keyPath: keyPath] }
        set { value?[keyPath: keyPath] = newValue }
    }
    
    /// 相等性比较，基于对象标识
    /// Equality comparison based on object identity
    public static func == (lhs: SKWeakBox<Value>, rhs: SKWeakBox<Value>) -> Bool {
        lhs === rhs
    }
    
    /// 哈希函数，基于对象标识符
    /// Hash function based on object identifier
    public func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
    
}
