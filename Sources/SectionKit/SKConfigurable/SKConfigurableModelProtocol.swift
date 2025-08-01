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

/// 存在模型协议，要求类型具有关联的模型类型并支持使用模型初始化
/// Existing model protocol requiring types to have associated model type and support initialization with model
public protocol SKExistModelProtocol {
    /// 关联的模型类型
    /// Associated model type
    associatedtype Model
    
    /// 使用模型初始化
    /// Initialize with model
    init(model: Model)
}

/// 可配置模型协议，要求类型具有关联的模型类型并支持配置
/// Configurable model protocol requiring types to have associated model type and support configuration
public protocol SKConfigurableModelProtocol {
    /// 关联的模型类型
    /// Associated model type
    associatedtype Model
    
    /// 使用模型配置实例
    /// Configure instance with model
    func config(_ model: Model)
}

public extension SKConfigurableModelProtocol where Model == Void {
    /// 为 Void 模型类型提供默认空实现
    /// Provide default empty implementation for Void model type
    func config(_: Model) {}
}
