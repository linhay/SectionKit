//
//  File.swift
//  
//
//  Created by linhey on 2022/8/11.
//

import UIKit

protocol STCollectionViewDataSourcePrefetchingProtocol {
    func prefetch(at rows: [Int])
    func cancelPrefetching(at rows: [Int])
}
