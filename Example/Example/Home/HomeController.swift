//
//  ViewController.swift
//  Example
//
//  Created by linhey on 2022/3/12.
//

import SectionUI
#if canImport(UIKit)
import UIKit

class HomeController: SKCollectionViewController {
    enum Action: String, CaseIterable {
        case singleTypeSection
        case prefetch
        case decoration
        case plugins
        case layoutPlugin
        case photos
    }
    
    let section = SKCSingleTypeSection<StringRawCell<Action>>()
    
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
        section.onCellAction(.selected) { result in
            var controller: UIViewController?
            switch result.model {
            case .photos:
                controller = BrowerController()
            case .prefetch:
                controller = PrefetchViewController()
                break
            case .singleTypeSection:
                controller = SingleTypeViewController()
            case .decoration:
                controller = DecorationViewController()
            case .plugins:
                controller = PluginsController()
            case .layoutPlugin:
                controller = LayoutPluginViewController()
            }
            guard let controller = controller else {
                return
            }
            controller.title = result.model
                .rawValue
                .enumerated()
                .map { $0.offset > 0 ? $0.element.description : $0.element.uppercased() }
                .joined()
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func setupUI() {
        section.sectionInset = .init(top: 20, left: 20, bottom: 0, right: 20)
        section.minimumLineSpacing = 8
        manager.reload(section)
        manager.scrollObserver.add(scroll: "1") { hander in
            
        }
        manager.scrollObserver.add(scroll: "1") { hander in
            
        }
    }
}

#endif
