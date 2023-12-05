//
//  SKCSingleTypeSection+HighPerformance.swift
//  SectionKit2
//
//  Created by linhey on 2023/12/4.
//

import Foundation

public extension SKCSingleTypeSection {
    
    typealias HighPerformanceIDBlock = (_ context: ModelDisplayedContext) -> String?
    
    @discardableResult
    func setHighPerformance(_ value: SKHighPerformanceStore<String>?) -> Self {
        highPerformance = value
        return self
    }
    
    @discardableResult
    func highPerformanceID(by block: HighPerformanceIDBlock?) -> Self {
        highPerformanceID = block
        if block != nil {
            return setHighPerformance(highPerformance ?? .init())
        } else {
            return setHighPerformance(nil)
        }
    }
    
    @discardableResult
    func highPerformanceID(by path: KeyPath<ModelDisplayedContext, Int?>) -> Self {
        return highPerformanceID { context in
            context[keyPath: path]?.description
        }
    }
    
    @discardableResult
    func highPerformanceID(by path: KeyPath<ModelDisplayedContext, Int>) -> Self {
        return highPerformanceID { context in
            context[keyPath: path].description
        }
    }
    
}
