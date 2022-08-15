//
//  STReusableRegistration_UICollectionView.swift
//  
//
//  Created by linhey on 2022/8/12.
//

import UIKit

public protocol STCollectionReusableViewRegistrationProtocol: AnyObject, STViewRegistrationProtocol where View: UICollectionReusableView {
    
    typealias VoidBlock = () -> Void
    typealias VoidInputBlock = (View.Model) -> Void
    
    var kind: SKSupplementaryKind { get }
    
    var onWillDisplay: VoidBlock? { get set }
    var onEndDisplaying: VoidBlock? { get set }
}

public extension STCollectionReusableViewRegistrationProtocol {
    
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


public extension STCollectionReusableViewRegistrationProtocol {
    
    private func wrapper(_ block: @escaping VoidInputBlock) -> VoidBlock {
        return { [weak self] in
            guard let self = self else { return }
            block(self.model)
        }
    }
    
    func onWillDisplay(_ block: @escaping VoidInputBlock) -> Self {
        onWillDisplay = wrapper(block)
        return self
    }
    
    func onEndDisplaying(_ block: @escaping VoidInputBlock) -> Self {
        onEndDisplaying = wrapper(block)
        return self
    }
    
}
