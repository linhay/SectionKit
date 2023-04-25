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

public class SKHighPerformanceStore<ID: Hashable> {
    
    public struct CacheKey: Hashable {
        
        public let id: ID
        public let size: CGSize
        
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(size.width)
            hasher.combine(size.height)
        }
        
    }
    
    public let sizeCached: SKKVCache<CacheKey, CGSize>
    
    public init(sizeCached: SKKVCache<CacheKey, CGSize> = .init()) {
        self.sizeCached = sizeCached
    }
    
    @discardableResult
    public func cache(by id: ID,
                      limit: CGSize,
                      calculate: (_ limit: CGSize) -> CGSize) -> CGSize {
        let key = CacheKey(id: id, size: limit)
        if let value = sizeCached.value(forKey: key) {
            return value
        }
        let calculate = calculate(limit)
        sizeCached.update(calculate, forKey: key)
        return calculate
    }
    
}

#endif
