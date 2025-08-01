//
//  SKKVCache.swift
//  SectionKit
//
//  Created by linhey on 2023/4/25.
//

#if canImport(ObjectiveC)
import ObjectiveC
import Foundation

// MARK: - 键值缓存 / Key-Value Cache

/// 高性能键值缓存类，支持过期时间和自动清理
/// High-performance key-value cache class with expiration time and automatic cleanup support
public final class SKKVCache<Key: Hashable, Value> {
    
    /// 底层 NSCache 包装器
    /// Underlying NSCache wrapper
    public let wrapped = NSCache<WrappedKey, Entry>()
    
    /// 日期提供器，用于计算过期时间
    /// Date provider for calculating expiration time
    public var dateProvider: (() -> Date)?
    
    /// 键跟踪器，用于跟踪缓存中的键
    /// Key tracker for tracking keys in cache
    public let keyTracker = KeyTracker()
    
    /// 缓存中的项目数量
    /// Number of items in cache
    public var count: Int { keyTracker.keys.count }
    
    /// 缓存数量限制
    /// Cache count limit
    public var countLimit: Int {
        set { wrapped.countLimit = newValue }
        get { wrapped.countLimit }
    }
    
    /// 初始化缓存
    /// Initialize cache
    public init(countLimit: Int? = nil,
                dateProvider: (() -> Date)? = nil) {
        wrapped.delegate = keyTracker
        self.dateProvider = dateProvider
        if let countLimit = countLimit {
            self.countLimit = countLimit
        }
    }
    
    /// 插入值到缓存，可指定生存时间
    /// Insert value into cache with optional lifetime
    public func insert(_ value: Value, forKey key: Key, lifeTime: TimeInterval? = nil) {
        let date: Date?
        if let lifeTime = lifeTime {
            date = dateProvider?().addingTimeInterval(lifeTime)
        } else {
            date = nil
        }
        self.insert(Entry(key: key, value: value, expirationDate: date))
    }
    
    /// 移除指定键的值
    /// Remove value for specified key
    public func remove(_ key: Key) {
        self[key] = nil
    }
    
    /// 移除所有缓存项
    /// Remove all cache items
    public func removeAll() {
        keyTracker.keys.removeAll()
        wrapped.removeAllObjects()
    }
}

// MARK: - Cache Subscript

public extension SKKVCache {
    
    subscript(_ key: WrappedKey) -> Entry? {
        get { entry(of: key) }
        set {
            remove(key)
            guard let newValue = newValue else { return }
            insert(newValue)
        }
    }
    
    subscript(_ key: Key) -> Value? {
        get { self[WrappedKey(key)]?.value }
        set { self[WrappedKey(key)] = newValue.map({ .init(key: key, value: $0) }) }
    }
    
}

// MARK: Cache.WrappedKey

public extension SKKVCache {
    
    final class WrappedKey: NSObject {
        public let key: Key
        public init(_ key: Key) { self.key = key }
        public override var hash: Int { key.hashValue }
        public override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            return value.key == key
        }
        
    }
}

// MARK: Cache.Entry

public extension SKKVCache {
    
    final class Entry {
        public let key: Key
        public let value: Value
        public let expirationDate: Date?
        
        public init(key: Key, value: Value, expirationDate: Date? = nil) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
    
}

// MARK: Cache.KeyTracker

public extension SKKVCache {
    
    final class KeyTracker: NSObject, NSCacheDelegate {
        public var keys = Set<Key>()
        
        public func cache(_: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
            guard let entry = obj as? Entry else {
                return
            }
            keys.remove(entry.key)
        }
    }
    
}

// MARK: - Cache.Entry + Codable

extension SKKVCache.Entry: Codable where Key: Codable, Value: Codable {}

private extension SKKVCache {
    
    func entry(of key: WrappedKey) -> Entry? {
        guard let entry = wrapped.object(forKey: key) else {
            return nil
        }
        
        if let expirationDate = entry.expirationDate,
           let now = dateProvider?(),
           now >= expirationDate {
            remove(key)
            return nil
        }
        
        return entry
    }
    
    func remove(_ key: WrappedKey) {
        keyTracker.keys.remove(key.key)
        wrapped.removeObject(forKey: key)
    }
    
    func insert(_ entry: Entry) {
        keyTracker.keys.insert(entry.key)
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
    }
}

// MARK: - Cache + Codable

extension SKKVCache: Codable where Key: Codable, Value: Codable {
    
    public convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.singleValueContainer()
        let entries = try container.decode([Entry].self)
        entries.forEach(insert)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(keyTracker.keys.compactMap({ self.entry(of: .init($0)) }))
    }
    
}
#endif
