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
        case singleTypeSection = "SingleTypeSection"
        case prefetch
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
        section.selectedEvent.delegate(on: self) { (self, action) in
            switch action {
            case .prefetch:
                self.navigationController?.pushViewController(PrefetchViewController(), animated: true)
            case .singleTypeSection:
                self.navigationController?.pushViewController(SingleTypeSectionViewController(), animated: true)
            }
        }
    }
    
    func setupUI() {
        section.sectionInset = .init(top: 20, left: 20, bottom: 0, right: 20)
        section.minimumLineSpacing = 8
        manager.update(section)
    }
    
}
