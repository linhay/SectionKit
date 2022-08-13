//
//  File.swift
//  
//
//  Created by linhey on 2022/8/11.
//

import UIKit

class STCollectionViewDataSourcePrefetching: NSObject, UICollectionViewDataSourcePrefetching {
    
    var section: (_ index: Int) -> STCollectionViewDataSourcePrefetchingProtocol?
    
    init(section: @escaping (_ indexPath: Int) -> STCollectionViewDataSourcePrefetchingProtocol?) {
        self.section = section
        super.init()
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        prefetch(at: indexPaths)
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        cancelPrefetch(at: indexPaths)
    }
    
}

private extension STCollectionViewDataSourcePrefetching {
    
    func prefetch(at indexPaths: [IndexPath]) {
        indexPaths.reduce([Int: [Int]]()) { result, indexPath in
            var result = result
            if let list = result[indexPath.section] {
                result[indexPath.section] = list + [indexPath.row]
            } else {
                result[indexPath.section] = [indexPath.row]
            }
            
            return result
        }.forEach { result in
            section(result.key)?.prefetch(at: result.value)
        }
    }
    
    func cancelPrefetch(at indexPaths: [IndexPath]) {
        indexPaths.reduce([Int: [Int]]()) { result, indexPath in
            var result = result
            
            if let list = result[indexPath.section] {
                result[indexPath.section] = list + [indexPath.row]
            } else {
                result[indexPath.section] = [indexPath.row]
            }
            
            return result
        }.forEach { result in
            section(result.key)?.cancelPrefetching(at: result.value)
        }
    }
    
}
