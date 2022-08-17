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

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI()
    }

    func bindUI() {
        leftController.section.registrations.forEach { item in
            item.onSelected { _ in
                self.rightController.send(item.model as! SingleTypeSectionViewController.Action)
            }
        }
//        leftController.section.onItemSelected(on: self) { (self, _, action) in
//            self.rightController.send(action)
//        }
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
        
        let section = SKCRegistrationSection()
        
        lazy var stmanager = STCollectionManager(sectionView: sectionView)

        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
        }

        func setupUI() {
            section.registrations = StringRawCell<Action>.registration(Action.allCases)
// section.sectionInset = .init(top: 20, left: 8, bottom: 0, right: 8)
// section.minimumLineSpacing = 8
            stmanager.update([section])
        }
        
    }
}

extension SingleTypeSectionViewController {
    class RightViewController: SKCollectionViewController {
        let size = CGSize(width: 88, height: 44)

        lazy var section = SingleTypeSection<ColorBlockCell>((0 ... 10).map { offset in
            .init(color: .white, text: offset.description, size: size)
        })

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
                let models = section.models.enumerated().map { offset, _ in
                    ColorBlockCell.Model(color: .white,
                                         text: offset.description,
                                         size: size)
                }
                section.config(models: models)
            case .add:
                section.config(models: section.models + [.init(color: StemColor.random.alpha(with: 0.4).convert(),
                                                               text: "\(section.models.count) New",
                                                               size: size)])
            case .insert:
                guard section.models.isEmpty == false,
                      let offset = (0 ... section.models.count - 1).randomElement()
                else {
                    return
                }
                section.insert(.init(color: StemColor.random.alpha(with: 0.4).convert(),
                                     text: "\(offset) New",
                                     size: size),
                               at: offset)
            case .deleteModel:
                guard section.models.isEmpty == false,
                      let offset = (0 ... section.models.count - 1).randomElement()
                else {
                    return
                }
                section.cellForTypeItem(at: offset)?.isHighlighted = true
                animate {
                    self.section.remove(self.section.models[offset])
                }
            case .delete:
                guard section.models.isEmpty == false,
                      let offset = (0 ... section.models.count - 1).randomElement()
                else {
                    return
                }
                section.cellForTypeItem(at: offset)?.isHighlighted = true
                animate {
                    self.section.remove(at: [offset])
                }
            case .swap:
                guard section.models.isEmpty == false,
                      let offset1 = (0 ... section.models.count - 1).randomElement(),
                      let offset2 = (0 ... section.models.count - 1).randomElement()
                else {
                    return
                }
                section.cellForTypeItem(at: offset1)?.isHighlighted = true
                section.cellForTypeItem(at: offset2)?.isHighlighted = true
                animate {
                    self.section.moveItem(at: offset1, to: offset2)
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
            manager.update(section)
        }
    }
}
