//
//  SingleTypeSectionViewController.swift
//  Example
//
//  Created by linhey on 2022/3/12.
//

import SectionUI
import Stem
import UIKit
import StemColor

class SingleTypeViewController: SKCollectionViewController {
    
    enum Action: String, CaseIterable {
        case reload
        case reset
        case add
        case delete
        case delete_model = "delete.model"
        case insert
        case swap
        case select
        case setHeader
        case setFooter
        case removeHeader
        case removeFooter
    }
    
    let leftController = LeftViewController()
    let rightController = RightViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI()
    }
    
    func bindUI() {
        leftController.section
            .onCellAction(.selected) { [weak self] result in
                guard let self = self else { return }
                self.rightController.send(result.model)
            }
    }
    
    func setupUI() {
        addChild(leftController)
        addChild(rightController)
        view.addSubview(leftController.view)
        view.addSubview(rightController.view)
        leftController.view.snp.makeConstraints { make in
            make.top.bottom.left.equalToSuperview()
            make.width.equalTo(128)
        }
        rightController.view.snp.makeConstraints { make in
            make.top.bottom.right.equalToSuperview()
            make.left.equalTo(leftController.view.snp.right)
        }
    }
}

extension SingleTypeViewController {
    
    class LeftViewController: SKCollectionViewController {
        
        let section = StringRawCell
            .singleTypeWrapper(builder: {
                Action.allCases
            })
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
        }
        
        func setupUI() {
            section.sectionInset = .init(top: 20, left: 8, bottom: 0, right: 8)
            section.minimumLineSpacing = 8
            manager.reload([section])
        }
        
    }
}

extension SingleTypeViewController {
    
    class RightViewController: SKCollectionViewController {
        let size = CGSize(width: 60, height: 60)
        
        lazy var defaultModels = (0 ... 10).map { offset in
            ColorBlockCell.Model(color: .white, text: offset.description, size: size)
        }
        
        lazy var section = SKCSingleTypeSection<ColorBlockCell>(defaultModels)
        
        var isAnimating = false
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
        }
        
        func send(_ action: Action) {
            guard isAnimating == false else {
                return
            }
            switch action {
            case .reload:
                manager.sectionView?.reloadData()
            case .select:
                section.selectItem(at: (0..<section.itemCount).randomElement()!)
            case .reset:
                section.config(models: defaultModels)
            case .add:
                section.append(.init(color: StemColor.random.alpha(with: 0.4).convert(),
                                     text: "\(section.models.count) New",
                                     size: size))
            case .insert:
                let offset = (0..<section.itemCount).randomElement()!
                section.insert(at: offset,
                               .init(color: StemColor.random.alpha(with: 0.4).convert(),
                                     text: "\(offset) New",
                                     size: size))
            case .delete_model:
                guard let model = section.models.randomElement() else {
                    return
                }
                section.rows(with: model).forEach({ row in
                    section.cellForItem(at: row)?.isHighlighted = true
                })
                animate {
                    self.section.remove(model)
                }
            case .delete:
                guard section.models.isEmpty == false,
                      let offset = (0 ... section.models.count - 1).randomElement()
                else {
                    return
                }
                section.cellForItem(at: offset)?.isHighlighted = true
                animate {
                    self.section.remove([offset])
                }
            case .swap:
                guard section.models.isEmpty == false,
                      let model1 = section.models.randomElement(),
                      let model2 = section.models.randomElement()
                else {
                    return
                }
                let row1 = section.rows(with: model1)
                let row2 = section.rows(with: model2)

                row1.forEach({ row in
                    section.cellForItem(at: row)?.isHighlighted = true
                })
                row2.forEach({ row in
                    section.cellForItem(at: row)?.isHighlighted = true
                })
                animate {
                    self.section.swapAt(row1.first!, row2.first!)
                } finish: {
                    self.section.rows(with: model1).forEach({ row in
                        self.section.cellForItem(at: row)?.isHighlighted = false
                    })
                    self.section.rows(with: model2).forEach({ row in
                        self.section.cellForItem(at: row)?.isHighlighted = false
                    })
                }
            case .setHeader:
                section.set(supplementary: SKCSupplementary(kind: .header, type: ReusableView.self, model: "header"))
            case .setFooter:
                section.set(supplementary: SKCSupplementary(kind: .footer, type: ReusableView.self, model: "footer"))
            case .removeHeader:
                section.remove(supplementary: .header)
            case .removeFooter:
                section.remove(supplementary: .footer)
            }
        }
        
        func animate(_ event: @escaping () -> Void, finish: (() -> Void)? = nil) {
            isAnimating = true
            Gcd.delay(.main, seconds: 0.5) {
                event()
                Gcd.delay(.main, seconds: 0.5) {
                    self.isAnimating = false
                    finish?()
                }
            }
        }
        
        func setupUI() {
            section.sectionInset = .init(top: 20, left: 8, bottom: 0, right: 8)
            section.minimumLineSpacing = 2
            manager.reload(section)
        }
    }
}
