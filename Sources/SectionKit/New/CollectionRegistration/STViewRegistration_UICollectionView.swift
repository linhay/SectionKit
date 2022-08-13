//
//  STReusableRegistration_UICollectionView.swift
//  
//
//  Created by linhey on 2022/8/12.
//

import UIKit

public protocol STCollectionReusableViewRegistrationProtocol: STViewRegistrationProtocol where View: UICollectionReusableView {
    var kind: SKSupplementaryKind { get }
}

extension STViewRegistrationProtocol where View: UICollectionViewCell {
    
    func dequeue(sectionView: UICollectionView) -> View {
        guard let indexPath = indexPath else {
            assertionFailure()
            return .init()
        }
        let view = sectionView.dequeueReusableCell(withReuseIdentifier: View.identifier, for: indexPath) as! View
        view.config(model)
        return view
    }
    
    func register(sectionView: UICollectionView) {
        if let nib = View.nib {
            sectionView.register(nib, forCellWithReuseIdentifier: View.identifier)
        } else {
            sectionView.register(View.self, forCellWithReuseIdentifier: View.identifier)
        }
    }
    
}

extension STViewRegistrationProtocol where View: UICollectionReusableView {
    
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
    
    func register(sectionView: UICollectionView, for kind: SKSupplementaryKind) {
        if let nib = View.nib {
            sectionView.register(nib, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: View.identifier)
        } else {
            sectionView.register(View.self, forSupplementaryViewOfKind: kind.rawValue, withReuseIdentifier: View.identifier)
        }
    }
    
}
