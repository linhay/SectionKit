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
        
        func newSection(_ text: String? = nil, count: Int) -> STCollectionRegistrationSection {
            STCollectionRegistrationSection(registrations: ColorBlockCell
                .registration((1...count).map({ idx in
                        .init(color: StemColor.random.convert(),
                              text: text ?? "\(manager.sections.count)-\(idx.description)",
                              size: .init(width: 60, height: 60))
                }))
            )
        }
        
        func on(action: Action) {
            switch action {
            case .reset:
                manager.update([
                    newSection("1", count: 1),
                    newSection("2", count: 2),
                    newSection("3", count: 3),
                    newSection("4", count: 4),
                    newSection("5", count: 5),
                    newSection("6", count: 6),
                    newSection("7", count: 7),
                    newSection("8", count: 8),
                ])
            case .insert:
                manager.insert(newSection(count: 4), at: manager.sections.indices.randomElement() ?? 0)
            case .append:
                manager.append(newSection(count: 4))
            case .remove:
                if let section = manager.sections.randomElement() {
                    manager.remove(section)
                }
            }
        }
    }
    
    
}
