//
//  File.swift
//  
//
//  Created by linhey on 2022/8/11.
//

#if canImport(UIKit)
import UIKit
import Combine

public class SKCViewDataSourcePrefetching: NSObject, UICollectionViewDataSourcePrefetching {

    public private(set) lazy var prefetchPublisher = deferred(bind: \.prefetch)
    public private(set) lazy var cancelPrefetchingPublisher = deferred(bind: \.cancelPrefetching)
    public var isEnable: Bool = false
    
    private var prefetch: PassthroughSubject<[IndexPath], Never>?
    private var cancelPrefetching: PassthroughSubject<[IndexPath], Never>?
    private var section: (_ index: Int) -> SKCViewDataSourcePrefetchingProtocol?
    
    func deferred<Output, Failure: Error>(bind: WritableKeyPath<SKCViewDataSourcePrefetching, PassthroughSubject<Output, Failure>?>) -> AnyPublisher<Output, Failure> {
        return Deferred { [weak self] in
            guard var self = self else {
                return PassthroughSubject<Output, Failure>()
            }
            if let subject = self[keyPath: bind] {
                return subject
            }
            let subject = PassthroughSubject<Output, Failure>()
            self[keyPath: bind] = subject
            return subject
        }
        .eraseToAnyPublisher()
    }

    init(section: @escaping (_ indexPath: Int) -> SKCViewDataSourcePrefetchingProtocol?) {
        self.section = section
        super.init()
    }
    
    public func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        prefetch(at: indexPaths)
    }
    
    public func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        cancelPrefetch(at: indexPaths)
    }
    
}

private extension SKCViewDataSourcePrefetching {
    
    func prefetch(at indexPaths: [IndexPath]) {
        guard isEnable else { return }
        prefetch?.send(indexPaths)
        var store = [Int: [Int]]()
        for indexPath in indexPaths {
            if store[indexPath.section] == nil {
                store[indexPath.section] = [indexPath.row]
            } else {
                store[indexPath.section]?.append(indexPath.row)
            }
        }
        for (key, value) in store {
            section(key)?.prefetch(at: value)
        }
    }
    
    func cancelPrefetch(at indexPaths: [IndexPath]) {
        guard isEnable else { return }
        cancelPrefetching?.send(indexPaths)
        var store = [Int: [Int]]()
        for indexPath in indexPaths {
            if store[indexPath.section] == nil {
                store[indexPath.section] = [indexPath.row]
            } else {
                store[indexPath.section]?.append(indexPath.row)
            }
        }
        for (key, value) in store {
            section(key)?.cancelPrefetching(at: value)
        }
    }
    
}

#endif