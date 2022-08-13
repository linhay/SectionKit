//
//  STReusableRegistration_UICollectionView.swift
//
//
//  Created by linhey on 2022/8/12.
//

import UIKit

protocol STTableCellRegistrationProtocol: STViewRegistrationProtocol where View: UICollectionViewCell {}
protocol STHeaderFooterViewRegistrationProtocol: STViewRegistrationProtocol where View: UITableViewHeaderFooterView {}

extension STViewRegistrationProtocol where View: UITableViewCell {
    
    func dequeue(sectionView: UITableView) -> View {
        guard let indexPath = indexPath else {
            assertionFailure()
            return .init()
        }
        let view = sectionView.dequeueReusableCell(withIdentifier: View.identifier, for: indexPath) as! View
        view.config(model)
        return view
    }
    
    func register(sectionView: UITableView) {
        if let nib = View.nib {
            sectionView.register(nib, forHeaderFooterViewReuseIdentifier: View.identifier)
        } else {
            sectionView.register(View.self, forHeaderFooterViewReuseIdentifier: View.identifier)
        }
    }
    
}

extension STViewRegistrationProtocol where View: UITableViewHeaderFooterView {
    
    func dequeue(sectionView: UITableView, kind: SKSupplementaryKind) -> View {
        let view = sectionView.dequeueReusableHeaderFooterView(withIdentifier: View.identifier) as! View
        view.config(model)
        return view
    }
    
    func register(sectionView: UITableView, for kind: SKSupplementaryKind) {
        if let nib = View.nib {
            sectionView.register(nib, forHeaderFooterViewReuseIdentifier: View.identifier)
        } else {
            sectionView.register(View.self, forHeaderFooterViewReuseIdentifier: View.identifier)
        }
    }
    
}
