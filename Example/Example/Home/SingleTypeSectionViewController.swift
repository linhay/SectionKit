//
//  SingleTypeSectionViewController.swift
//  Example
//
//  Created by linhey on 2022/3/12.
//

import SectionKit
import Stem
import UIKit
import StemColor

class SingleTypeSectionViewController: SKCollectionViewController {
    
    enum Action: String, CaseIterable {
        case reset
        case add
        case delete
        case deleteModel = "delete.model"
        case insert
        case swap
        case select
    }
    
    let leftController = LeftViewController()
    let rightController = RightViewController()
    
    lazy var stmanager = STCollectionManager(sectionView: sectionView)
    
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

extension SingleTypeSectionViewController {
    
    class LeftViewController: SKCollectionViewController {
        
        let section = StringRawCell<Action>.singleTypeWrapper(Action.allCases)
        
        lazy var stmanager = STCollectionManager(sectionView: sectionView)
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
        }
        
        func setupUI() {
            section.sectionInset = .init(top: 20, left: 8, bottom: 0, right: 8)
            section.minimumLineSpacing = 8
            stmanager.update([section])
        }
        
    }
}

extension SingleTypeSectionViewController {
    
    class RightViewController: SKCollectionViewController {
        let size = CGSize(width: 88, height: 44)
        
        lazy var defaultModels = (0 ... 10).map { offset in
            ColorBlockCell.Model(color: .white, text: offset.description, size: size)
        }
        
        lazy var section = SKCSingleTypeSection<ColorBlockCell>(defaultModels)
        
        lazy var skmanager = STCollectionManager(sectionView: sectionView)
        
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
            case .select:
                guard section.models.isEmpty == false,
                      let offset = (0 ... section.models.count - 1).randomElement()
                else {
                    return
                }
                section.selectItem(at: offset, animated: true, scrollPosition: .centeredVertically)
            case .reset:
                section.config(models: defaultModels)
            case .add:
                section.append(.init(color: StemColor.random.alpha(with: 0.4).convert(),
                                     text: "\(section.models.count) New",
                                     size: size))
            case .insert:
                guard section.models.isEmpty == false,
                      let offset = (0 ... section.models.count - 1).randomElement()
                else {
                    return
                }
                section.insert(at: offset,
                               .init(color: StemColor.random.alpha(with: 0.4).convert(),
                                     text: "\(offset) New",
                                     size: size))
            case .deleteModel:
                guard section.models.isEmpty == false,
                      let offset = (0 ... section.models.count - 1).randomElement()
                else {
                    return
                }
                section.cellForItem(at: offset)?.isHighlighted = true
                animate {
                    self.section.remove(self.section.models[offset])
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
                      let offset1 = (0 ... section.models.count - 1).randomElement(),
                      let offset2 = (0 ... section.models.count - 1).randomElement()
                else {
                    return
                }
                section.cellForItem(at: offset1)?.isHighlighted = true
                section.cellForItem(at: offset2)?.isHighlighted = true
                animate {
                    self.section.swapAt(offset1, offset2)
                }
            }
        }
        
        func animate(_ event: @escaping () -> Void) {
            isAnimating = true
            Gcd.delay(.main, seconds: 0.5) {
                self.isAnimating = false
                event()
            }
        }
        
        func setupUI() {
            section.sectionInset = .init(top: 20, left: 8, bottom: 0, right: 8)
            section.minimumLineSpacing = 8
            skmanager.update(section)
        }
    }
}
