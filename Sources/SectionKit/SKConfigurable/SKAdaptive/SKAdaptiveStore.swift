//
//  File.swift
//  
//
//  Created by linhey on 2023/4/25.
//

#if canImport(ObjectiveC) && canImport(UIKit)
import ObjectiveC
import Foundation
import CoreFoundation
import UIKit

public class SKAdaptiveIDStore<ID: Hashable> {
    
    public struct CacheKey: Hashable {
        
        public let id: ID
        public let size: CGSize
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(size.width)
            hasher.combine(size.height)
        }
        
    }
    
    public let cached: SKKVCache<CacheKey, CGSize>
    
    public init(cached: SKKVCache<CacheKey, CGSize> = .init()) {
        self.cached = cached
    }
    
    @discardableResult
    public func cache(by id: ID,
                      limit: CGSize,
                      calculate: (_ limit: CGSize) -> CGSize) -> CGSize {
        let key = CacheKey(id: id, size: limit)
        if let value = cached.value(forKey: key) {
            return value
        }
        let calculate = calculate(limit)
        cached.update(calculate, forKey: key)
        return calculate
    }
    
}

#endif
