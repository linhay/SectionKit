//
//  RegistrationViewController.swift
//  
//
//  Created by linhey on 2022/8/13.
//

import UIKit
import SectionKit
import StemColor

class RegistrationViewController: UIViewController {
    
    enum Action: String, CaseIterable {
        case insert
        case append
        case remove
        case reset
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let left = LeftViewController()
        addChild(left)
        view.addSubview(left.view)
        left.view.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.width.equalTo(100)
        }
        
        let right = RightViewController()
        addChild(right)
        view.addSubview(right.view)
        right.view.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(left.view.snp.right)
        }
        
        left.event.delegate(on: self) { (self, action) in
            right.on(action: action)
        }
    }
    
}

extension RegistrationViewController {
    
    class LeftViewController: UIViewController {
        
        let event = SectionDelegate<Action, Void>()
        
        let sectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        lazy var manager = STCollectionRegistrationManager(sectionView: sectionView)
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.addSubview(sectionView)
            sectionView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
            manager.update([STCollectionRegistrationSection(registrations:
                HomeIndexCell
                    .registration(Action.allCases)
                    .onSelected { model in
                        self.event.call(model)
                    }
            )])
        }
    }
    
    class RightViewController: UIViewController {
        
        let sectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        lazy var manager = STCollectionRegistrationManager(sectionView: sectionView)
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.addSubview(sectionView)
            sectionView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        func newSection() -> STCollectionRegistrationSection {
            STCollectionRegistrationSection(registrations: [
                ColorBlockCell.registration(.init(color: StemColor.random.convert(),
                                                  text: manager.sections.count.description,
                                                  size: .init(width: 60, height: 60)))
                ])
        }
        
        func on(action: Action) {
            switch action {
            case .reset:
                manager.update([newSection()])
            case .insert:
                manager.insert(newSection(), at: manager.sections.indices.randomElement() ?? 0)
            case .append:
                manager.append(newSection())
            case .remove:
                if let section = manager.sections.randomElement() {
                    manager.remove(section)
                }
            }
        }
    }
    
    
}
