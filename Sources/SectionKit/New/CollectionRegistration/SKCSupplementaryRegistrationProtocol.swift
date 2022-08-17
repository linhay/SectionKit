//
//  STReusableRegistration_UICollectionView.swift
//  
//
//  Created by linhey on 2022/8/12.
//

import UIKit

public protocol SKCSupplementaryRegistrationProtocol: AnyObject, SKViewRegistrationProtocol where View: UICollectionReusableView {
    
    typealias BoolBlock = () -> Bool
    typealias BoolInputBlock = (View.Model) -> Bool
    typealias VoidBlock = () -> Void
    typealias VoidInputBlock = (View.Model) -> Void
    
    var kind: SKSupplementaryKind { get }
    var injection: (any SKCRegistrationInjectionProtocol)? { get set }

    var onWillDisplay: VoidBlock? { get set }
    var onEndDisplaying: VoidBlock? { get set }
    
}

public extension SKCSupplementaryRegistrationProtocol {
    
    func dequeue(sectionView: UICollectionView, kind: SKSupplementaryKind) -> View {
        guard let indexPath = indexPath else {
            assertionFailure()
            return .init()
        }
        let view = sectionView.dequeueReusableSupplementaryView(ofKind: kind.rawValue,
                                                                withReuseIdentifier: View.identifier,
                                                                for: indexPath) as! View
        view.config(model)
        return view
    }
    
    func register(sectionView: UICollectionView) {
        if let nib = View.nib {
            sectionView.register(nib, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: View.identifier)
        } else {
            sectionView.register(View.self, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: View.identifier)
        }
    }
    
}

public extension SKCSupplementaryRegistrationProtocol {
    
    func onWillDisplay(_ block: @escaping VoidInputBlock) -> Self {
        onWillDisplay = wrapper(block)
        return self
    }
    
    func onEndDisplaying(_ block: @escaping VoidInputBlock) -> Self {
        onEndDisplaying = wrapper(block)
        return self
    }
    
}

extension SKCSupplementaryRegistrationProtocol {
    
     func wrapper(_ block: @escaping BoolInputBlock) -> BoolBlock {
        return { [weak self] in
            guard let self = self else { return false }
            return block(self.model)
        }
    }
    
     func wrapper(_ block: @escaping VoidInputBlock) -> VoidBlock {
        return { [weak self] in
            guard let self = self else { return }
            block(self.model)
        }
    }
    
}
