//
//  File.swift
//  
//
//  Created by linhey on 2023/4/25.
//

#if canImport(ObjectiveC)
import ObjectiveC
import Foundation
// MARK: - Cache
public final class SKKVCache<Key: Hashable, Value> {
    
    private let wrapped = NSCache<WrappedKey, Entry>()
    private let dateProvider: () -> Date
    private let keyTracker = KeyTracker()
    
    public init(dateProvider: @escaping () -> Date = Date.init,
                maximumEntryCount: Int = .max) {
        self.dateProvider = dateProvider
        wrapped.countLimit = maximumEntryCount
        wrapped.delegate = keyTracker
    }
    
    public func insert(_ value: Value, forKey key: Key, lifeTime: TimeInterval? = nil) {
        let date: Date?
        if let lifeTime = lifeTime {
            date = dateProvider().addingTimeInterval(lifeTime)
        } else {
            date = nil
        }
        let entry = Entry(key: key, value: value, expirationDate: date)
        wrapped.setObject(entry, forKey: WrappedKey(key))
        keyTracker.keys.insert(key)
    }
    
    public func update(_ value: Value, forKey key: Key) {
        if self.value(forKey: key) != nil {
            removeValue(forKey: key)
        }
        insert(value, forKey: key)
    }
    
    public func value(forKey key: Key) -> Value? {
        return entry(forKey: key)?.value
    }
    
    public func removeValue(forKey key: Key) {
        wrapped.removeObject(forKey: WrappedKey(key))
    }
}

// MARK: - Cache Subscript

public extension SKKVCache {
    subscript(key: Key) -> Value? {
        get { value(forKey: key) }
        set {
            guard let value = newValue else {
                // If nil was assigned using our subscript,
                // then we remove any value for that key:
                removeValue(forKey: key)
                return
            }
            
            insert(value, forKey: key)
        }
    }
}

// MARK: Cache.WrappedKey

private extension SKKVCache {
    final class WrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) { self.key = key }
        
        override var hash: Int { key.hashValue }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            
            return value.key == key
        }
    }
}

// MARK: Cache.Entry

private extension SKKVCache {
    
    final class Entry {
        let key: Key
        let value: Value
        let expirationDate: Date?
        
        init(key: Key, value: Value, expirationDate: Date?) {
            self.key = key
            self.value = value
            self.expirationDate = expirationDate
        }
    }
    
}

// MARK: Cache.KeyTracker

private extension SKKVCache {
    
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<Key>()
        
        func cache(_: NSCache<AnyObject, AnyObject>, willEvictObject obj: Any) {
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
    
    func entry(forKey key: Key) -> Entry? {
        guard let entry = wrapped.object(forKey: WrappedKey(key)) else {
            return nil
        }

        if let expirationDate = entry.expirationDate,
           dateProvider() >= expirationDate {
            removeValue(forKey: key)
            return nil
        }
        
        return entry
    }
    
    func insert(_ entry: Entry) {
        wrapped.setObject(entry, forKey: WrappedKey(entry.key))
        keyTracker.keys.insert(entry.key)
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
        try container.encode(keyTracker.keys.compactMap(entry))
    }
    
}
#endif
