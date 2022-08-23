//
//  File.swift
//  
//
//  Created by linhey on 2022/8/11.
//

import UIKit

protocol SKCViewDataSourcePrefetchingProtocol {
    func prefetch(at rows: [Int])
    func cancelPrefetching(at rows: [Int])
}
