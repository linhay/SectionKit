//
//  MultiSectionViewController.swift
//  Example
//
//  Created by linhey on 2022/3/14.
//

import UIKit
import SectionKit
import Stem

class MultiSectionViewController: SectionCollectionViewController {
    
    enum Action: String, CaseIterable {
        case reset
        case insert
        case delete
        case move
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

extension MultiSectionViewController {
    
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

extension MultiSectionViewController {
    
    class RightViewController: SectionCollectionViewController {
        let size = CGSize(width: 88, height: 44)
        
        typealias Section = SingleTypeSection<ColorBlockCell>
        
        func newSection() -> Section {
            let section = Section((0...4).map({ offset in
                    .init(color: .white, text: offset.description, size: size)
            }))
            section.cellStyleProvider.delegate(on: self) { (self, result) in
                result.cell.update(text: "\(section.index) - \(result.row)")
            }
            section.sectionInset = .init(top: 20, left: 8, bottom: 0, right: 8)
            section.minimumLineSpacing = 8
            return section
        }
        
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
            case .reset:
                manager.reload()
            case .insert:
                let section = newSection()
                
                if manager.sections.isEmpty == false, let random = (0..<manager.sections.count).randomElement() {
                    manager.insert(section, at: random)
                } else {
                    manager.update(newSection())
                }
                
                section.visibleTypeItems.forEach { cell in
                    cell.setHighlight()
                }
                animate {
                    section.visibleTypeItems.forEach { cell in
                        cell.unhighlight()
                    }
                }
            case .delete:
                guard manager.sections.isEmpty == false, let random = manager.sections.randomElement() as? Section else {
                    return
                }
                random.visibleTypeItems.forEach { cell in
                    cell.setHighlight()
                }
                animate {
                    self.manager.delete(random)
                }
            case .move:
                guard let random1 = manager.sections.randomElement() as? Section,
                      let random2 = manager.sections.randomElement() as? Section else {
                    return
                }
                [random1, random2].map(\.visibleTypeItems).joined().forEach { cell in
                    cell.setHighlight()
                }
                self.manager.move(from: .section(random1), to: .section(random2))
                animate {
                    [random1, random2].map(\.visibleTypeItems).joined().forEach { cell in
                        cell.unhighlight()
                    }
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
            manager.update(newSection())
        }
        
    }
    
}
