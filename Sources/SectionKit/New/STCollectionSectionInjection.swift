//
//  File.swift
//  
//
//  Created by linhey on 2022/8/13.
//

import UIKit
import Combine

public class STCollectionSectionInjection {
    
    public struct Action: OptionSet, Hashable {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
    
    class SectionViewProvider {
        var sectionView: UICollectionView?
        
        init(_ sectionView: UICollectionView?) {
            self.sectionView = sectionView
        }
    }
    
    public let index: Int
    public var sectionView: UICollectionView? { sectionViewProvider.sectionView }
    
    var sectionViewProvider: SectionViewProvider
    
    private var events: [Action: (STCollectionSectionInjection) -> Void] = [:]
    
    init(index: Int, sectionView: SectionViewProvider) {
        self.sectionViewProvider = sectionView
        self.index = index
    }
    
}

public extension STCollectionSectionInjection.Action {
    
    static let reload = Self(rawValue: 1 << 1)
    static let delete = Self(rawValue: 1 << 2)
    
}

public extension STCollectionSectionInjection {
    
    func reset(_ events: [Action: (STCollectionSectionInjection) -> Void]) {
        self.events = events
    }
    
    func send(_ action: Action) {
        guard let event = events[action] else {
            assertionFailure()
            return
        }
        event(self)
    }
    
}
