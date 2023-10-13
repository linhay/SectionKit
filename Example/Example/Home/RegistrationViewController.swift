//
//  RegistrationViewController.swift
//  
//
//  Created by linhey on 2022/8/13.
//

#if canImport(UIKit)
import UIKit
import SectionKit
import StemColor
import Delegate

class RegistrationViewController: UIViewController {
    
    enum Action: String, CaseIterable {
        case reset          = "重置"
        case section_insert = "组-插入"
        case section_append = "组-拼接"
        case section_remove = "组-移除"
        case cell_insert    = "cell-插入"
        case cell_append    = "cell-拼接"
        case cell_remove    = "cell-移除"
        case cell_self_remove = "cell-self-移除"
        case cell_self_reload = "cell-self-重载"
        case view_insert    = "view-插入"
        case view_append    = "view-拼接"
        case view_remove    = "view-移除"
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
        
        let event = Delegate<Action, Void>()
        
        let sectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        lazy var manager = SKCRegistrationManager(sectionView: sectionView)
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.addSubview(sectionView)
            sectionView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            
           let section = SKCRegistrationSection {
                StringRawCell
                    .registration(Action.allCases)
                    .onSelected { model in
                        self.event.call(model)
                    }
            }
            
            manager.reload([section])
        }
    }
    
    class RightViewController: UIViewController {
        
        let sectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        lazy var manager = SKCRegistrationManager(sectionView: sectionView)
        
        override func viewDidLoad() {
            super.viewDidLoad()
            view.addSubview(sectionView)
            sectionView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
        
        func newSection(_ text: String? = nil, count: Int) -> SKCRegistrationSection {
            SKCRegistrationSection {
                ReusableView.registration(.init(stringLiteral: "\(count.description) header"), for: .header)
                ReusableView.registration(.init(stringLiteral: "\(count.description) footer"), for: .footer)
                ColorBlockCell
                    .registration((1...count)
                        .map({ idx in
                        .init(color: StemColor.random.convert(),
                              text: text ?? "\(self.manager.sections.count)-\(idx.description)",
                              size: .init(width: 60, height: 60))
                }))
                
                for _ in 0...2 {
                    StringCell
                        .registration(.init(text: "cell-end",
                                            size: .init(width: 100, height: 40)))
                }
            }
        }
        
        func on(action: Action) {
            switch action {
            case .reset:
                manager.reload([
                    newSection("1", count: 1),
                    newSection("2", count: 2),
                    newSection("3", count: 3),
                    newSection("4", count: 4),
                    newSection("5", count: 5),
                    newSection("6", count: 6),
                    newSection("7", count: 7),
                    newSection("8", count: 8),
                ])
            case .section_insert:
                manager.insert(newSection(count: 4), at: manager.sections.indices.randomElement() ?? 0)
            case .section_append:
                manager.append(newSection(count: 4))
            case .section_remove:
                if let section = manager.sections.randomElement() {
                    manager.remove(section)
                }
            case .cell_insert:
                break
            case .cell_append:
                break
            case .cell_remove:
                if let section = manager.sections.randomElement(),
                   let cell = section.registrations.randomElement() {
                    section.delete(cell: cell)
                }
            case .cell_self_remove:
                if let section = manager.sections.randomElement(),
                   let cell = section.registrations.randomElement() {
                    cell.injection?.delete()
                }
            case .cell_self_reload:
                if let section = manager.sections.randomElement(),
                   let cell = section.registrations.randomElement() {
                    cell.injection?.reload()
                }
            case .view_insert:
                break
            case .view_append:
                break
                
            case .view_remove:
                if let section = manager.sections.randomElement(),
                   let view = section.supplementaries.randomElement()?.value {
                    section.delete(supplementary: view)
                }
                break
            }
        }
    }
    
    
}

#endif
