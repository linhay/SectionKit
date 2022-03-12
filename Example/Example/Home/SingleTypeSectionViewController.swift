//
//  SingleTypeSectionViewController.swift
//  Example
//
//  Created by linhey on 2022/3/12.
//

import UIKit
import SectionKit
import Stem

class SingleTypeSectionViewController: SectionCollectionViewController {

    enum Action: String, CaseIterable {
        case reset
        case add
        case delete
        case insert
    }
    
    let leftController = LeftViewController()
    let rightController = RightViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI()
    }
    
    func bindUI() {
        leftController.section.selectedEvent.delegate(on: self) { (self, action) in
            self.rightController.send(action)
        }
    }
    
    func setupUI() {
        title = "SingleTypeSectionViewController"
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
    
    class LeftViewController: SectionCollectionViewController {

        let section = SingleTypeSection<HomeIndexCell<Action>>(Action.allCases)

        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
        }
        
        func setupUI() {
            section.sectionInset = .init(top: 20, left: 8, bottom: 0, right: 8)
            section.minimumLineSpacing = 8
            manager.update(section)
        }
        
    }
    
}

extension SingleTypeSectionViewController {
    
    class RightViewController: SectionCollectionViewController {
        
        let section = SingleTypeSection<ColorBlockCell>()

        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
        }
        
        func send(_ action: Action) {
            let size = CGSize(width: 88, height: 44)
            switch action {
            case .reset:
                let models = section.models.enumerated().map { (offset, model) in
                    ColorBlockCell.Model.init(color: .white,
                                              text: offset.description,
                                              size: size)
                }
                section.config(models: models)
            case .add:
                section.config(models: section.models + [.init(color: StemColor.random.alpha(with: 0.4).convert(),
                                                               text: "\(section.models.count) New",
                                                               size: size)])
            case .insert:
                let offset = (0...section.models.count-1).randomElement()!
                section.insert(.init(color: StemColor.random.alpha(with: 0.4).convert(),
                                     text: "\(offset) New",
                                     size: size),
                               at: offset)
            case .delete:
                guard let offset = (0...section.models.count-1).randomElement() else {
                    return
                }
                section.delete(at: offset)
            }
        }
        
        func setupUI() {
            section.sectionInset = .init(top: 20, left: 8, bottom: 0, right: 8)
            section.minimumLineSpacing = 8
            manager.update(section)
        }
        
    }
    
}
