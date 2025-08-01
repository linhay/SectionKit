//
//  SKHighPerformanceStore.swift
//  SectionKit
//
//  Created by linhey on 2023/4/25.
//

#if canImport(ObjectiveC) && canImport(UIKit)
import ObjectiveC
import Foundation
import CoreFoundation

/// SK 高性能存储类，用于缓存尺寸计算结果以提升性能
/// SK high performance store class for caching size calculation results to improve performance
public class SKHighPerformanceStore<ID: Hashable> {
    
    /// 缓存键结构体，包含标识符和尺寸信息
    /// Cache key structure containing identifier and size information
    public struct CacheKey: Hashable {
        
        /// 标识符
        /// Identifier
        public let id: ID
        
        /// 尺寸信息
        /// Size information
        public let size: CGSize
        
        /// 哈希方法，用于在哈希表中存储
        /// Hash method for storing in hash table
        public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(size.width)
            hasher.combine(size.height)
        }
        
    }
    
    /// 尺寸缓存实例
    /// Size cache instance
    public var sizeCached: SKKVCache<CacheKey, CGSize>
    
    /// 初始化高性能存储
    /// Initialize high performance store
    public init(sizeCached: SKKVCache<CacheKey, CGSize> = .init()) {
        self.sizeCached = sizeCached
    }
    
}

public extension SKHighPerformanceStore {
    
    /// 根据 ID 和限制尺寸进行缓存计算
    /// Cache calculation based on ID and limit size
    @discardableResult
    func cache(by id: ID,
               limit: CGSize,
               calculate: (_ limit: CGSize) -> CGSize) -> CGSize {
        let key = CacheKey(id: id, size: limit)
        // 检查缓存中是否存在
        // Check if exists in cache
        if let value = sizeCached[key] {
            SKPrint.highPerformance("hit cache: id:\(key.id) size:\(value) limit:\(key.size)")
            return value
        }
        // 执行计算并缓存结果
        // Perform calculation and cache result
        let calculate = calculate(limit)
        sizeCached[key] = calculate
        SKPrint.highPerformance("cache: id:\(key.id) size:\(calculate) limit:\(key.size)")
        return calculate
    }
    
    @discardableResult
    func cache<T: AnyObject>(by object: T,
                             limit: CGSize,
                             calculate: (_ limit: CGSize) -> CGSize) -> CGSize where ID == ObjectIdentifier {
        return cache(by: ObjectIdentifier(object), limit: limit, calculate: calculate)
    }
    
    func remove<T: AnyObject>(by object: T, limit: CGSize) where ID == ObjectIdentifier {
        remove(by: ObjectIdentifier(object), limit: limit)
    }
    
    func remove(by id: ID, limit: CGSize) {
        sizeCached[.init(id: id, size: limit)] = nil
    }
    
    func removeAll() {
        sizeCached.removeAll()
    }
    
}

#endif
