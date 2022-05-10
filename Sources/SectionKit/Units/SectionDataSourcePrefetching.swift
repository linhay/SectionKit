//
//  File.swift
//
//
//  Created by linhey on 2022/3/12.
//

import UIKit

public protocol SectionDataSourcePrefetchingProtocol {
    var isPrefetchingEnabled: Bool { get }
    func prefetch(at rows: [Int])
    func cancelPrefetching(at rows: [Int])
}

public extension SectionDataSourcePrefetchingProtocol {
    var isPrefetchingEnabled: Bool { true }
    func prefetch(at _: [Int]) {}
    func cancelPrefetching(at _: [Int]) {}
}

class SectionDataSourcePrefetching: NSObject, UITableViewDataSourcePrefetching, UICollectionViewDataSourcePrefetching {
    let sectionEvent = SectionDelegate<Int, SectionDataSourcePrefetchingProtocol?>()
    
    private func prefetch(at indexPaths: [IndexPath]) {
        indexPaths.reduce([Int: [Int]]()) { result, indexPath in
            var result = result
            if let list = result[indexPath.section] {
                result[indexPath.section] = list + [indexPath.row]
            } else {
                result[indexPath.section] = [indexPath.row]
            }
            
            return result
        }.forEach { result in
            guard let section = sectionEvent.call(result.key),
                  section.isPrefetchingEnabled
            else {
                return
            }
            section.prefetch(at: result.value)
        }
    }
    
    private func cancelPrefetch(at indexPaths: [IndexPath]) {
        indexPaths.reduce([Int: [Int]]()) { result, indexPath in
            var result = result
            
            if let list = result[indexPath.section] {
                result[indexPath.section] = list + [indexPath.row]
            } else {
                result[indexPath.section] = [indexPath.row]
            }
            
            return result
        }.forEach { result in
            guard let section = sectionEvent.call(result.key),
                  section.isPrefetchingEnabled
            else {
                return
            }
            section.cancelPrefetching(at: result.value)
        }
    }
    
    func tableView(_: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        prefetch(at: indexPaths)
    }
    
    func tableView(_: UITableView, cancelPrefetchingForRowsAt indexPaths: [IndexPath]) {
        cancelPrefetch(at: indexPaths)
    }
    
    func collectionView(_: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        prefetch(at: indexPaths)
    }
    
    func collectionView(_: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        cancelPrefetch(at: indexPaths)
    }
}
