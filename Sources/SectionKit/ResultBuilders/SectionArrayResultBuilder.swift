//
//  SectionArrayResultBuilder.swift
//  SectionKit
//
//  Created by linhey on 2022/9/2.
//

import Foundation

/// Section 数组结果构建器，用于构建声明式的数据模型数组
/// Section array result builder for constructing declarative data model arrays
@resultBuilder
public class SectionArrayResultBuilder<Model> {
    
    /// 构建单个闭包表达式
    /// Build single closure expression
    public static func buildExpression(_ expression: () -> Model) -> [Model] {
        [expression()]
    }
    
    /// 构建数组表达式
    /// Build array expression
    public static func buildExpression(_ expression: [Model]) -> [Model] {
        expression
    }
    
    /// 构建单个模型表达式
    /// Build single model expression
    public static func buildExpression(_ expression: Model) -> [Model] {
        return [expression]
    }
    
    /// 构建空表达式
    /// Build empty expression
    public static func buildExpression(_ expression: ()) -> [Model] {
        return []
    }
    
    /// 构建条件分支的第一个组件
    /// Build first component of conditional branch
    public static func buildEither(first component: [Model]) -> [Model] {
        return component
    }
    
    /// 构建条件分支的第二个组件
    /// Build second component of conditional branch
    public static func buildEither(second component: [Model]) -> [Model] {
        return component
    }
    
    /// 构建可选组件
    /// Build optional component
    public static func buildOptional(_ component: [Model]?) -> [Model] {
        return component ?? []
    }
    
    /// 构建代码块，组合多个组件
    /// Build block combining multiple components
    public static func buildBlock(_ components: [Model]...) -> [Model] {
        buildArray(components)
    }
    
    /// 构建数组，将嵌套数组扁平化
    /// Build array by flattening nested arrays
    public static func buildArray(_ components: [[Model]]) -> [Model] {
        Array(components.joined())
    }
    
    /// 构建限制可用性的组件
    /// Build component with limited availability
    public static func buildLimitedAvailability(_ component: [Model]) -> [Model] {
        component
    }
    
}
