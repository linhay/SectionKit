//
//  File.swift
//  
//
//  Created by linhey on 2022/8/13.
//

import UIKit
import Combine

public class SKCSectionInjection {
    
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
    
    private var events: [Action: (SKCSectionInjection) -> Void] = [:]
    
    init(index: Int, sectionView: SectionViewProvider) {
        self.sectionViewProvider = sectionView
        self.index = index
    }
    
}

public extension SKCSectionInjection.Action {
    
    static let reload = Self(rawValue: 1 << 1)
    static let delete = Self(rawValue: 1 << 2)
    
}

public extension SKCSectionInjection {
    
    func reset(_ events: [Action: (SKCSectionInjection) -> Void]) -> Self {
        self.events = events
        return self
    }
    
    func send(_ action: Action) {
        guard let event = events[action] else {
            assertionFailure()
            return
        }
        event(self)
    }
    
}
