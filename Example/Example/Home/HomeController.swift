//
//  ViewController.swift
//  Example
//
//  Created by linhey on 2022/3/12.
//

import UIKit
import SectionKit

class HomeController: SectionCollectionViewController {
    
    enum Action: String, CaseIterable {
        case singleTypeSection
        case multiSection
        case prefetch
        case compositionalLayout
    }
    
    let section = SingleTypeSection<HomeIndexCell<Action>>()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI()
        reload()
    }
    
}

extension HomeController {
    
    func reload() {
        section.config(models: Action.allCases)
    }
    
}

extension HomeController {
    
    func bindUI() {
        section.onItemSelected(on: self) { (self, row, model) in
            var controller: UIViewController?
            switch model {
            case .compositionalLayout:
                controller = CompositionalViewController()
            case .prefetch:
                controller = PrefetchViewController()
            case .singleTypeSection:
                controller = SingleTypeSectionViewController()
            case .multiSection:
                controller = MultiSectionViewController()
            }
            guard let controller = controller else {
                return
            }
            controller.title = model.rawValue.enumerated().map { $0.offset > 0 ? $0.element.description : $0.element.uppercased() }.joined()
            self.navigationController?.pushViewController(controller, animated: true)
        }

    }
    
    func setupUI() {
        section.sectionInset = .init(top: 20, left: 20, bottom: 0, right: 20)
        section.minimumLineSpacing = 8
        manager.update(section)
    }
    
}
