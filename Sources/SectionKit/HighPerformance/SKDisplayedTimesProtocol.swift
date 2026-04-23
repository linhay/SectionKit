//
//  File.swift
//  
//
//  Created by linhey on 2023/7/20.
//

import Foundation

@MainActor
public protocol SKDisplayedTimesProtocol {
    var displayedTimes: SKCountedStore { get }
}
