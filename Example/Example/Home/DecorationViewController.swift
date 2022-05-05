//
//  File.swift
//  
//
//  Created by linhey on 2022/5/5.
//

import UIKit
import SectionKit
import Stem

class DecorationViewController: SectionCollectionViewController {
    
    enum Action: String, CaseIterable {
        case fix_insets
        case no_fix_insets
        case add
        case all
        case add_header
        case add_cells
        case add_footer
        case add_h_c
        case add_c_f
        case inset_10
        case inset_40
        case zIndex
    }
    
    let leftController = LeftViewController()
    let rightController = RightViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI()
    }
    
    func bindUI() {
        leftController.section.onItemSelected(on: self) { (self, row, action) in
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

extension DecorationViewController {
    
    class LeftViewController: SectionCollectionViewController {
        
        let section = HomeIndexCell<Action>.singleTypeWrapper(Action.allCases)
        
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

extension DecorationViewController {
    
    class RightViewController: SectionCollectionViewController {
        let size = CGSize(width: 88, height: 44)
        
        lazy var sections = (0...10).map { sectionIndex in
            ColorBlockCell
                .singleTypeWrapper((0...10).map({ index in
                        .init(color: .red, text: "\(sectionIndex - index)", size: size)
                }))
                .setHeader(ReusableView.self, model: "header - \(sectionIndex)")
                .setFooter(ReusableView.self, model: "footer - \(sectionIndex)")
        }
        
        var isAnimating = false
        var defaultPluginModes: [SectionCollectionFlowLayout.PluginMode] = [.fixSupplementaryViewInset(.all)]
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
        }
        
        func send(_ action: Action) {
            guard isAnimating == false else {
                return
            }
            switch action {
            case .zIndex:
                update(
                    .init(sectionIndex: .init(sections.first!), viewType: ReusableView.self, zIndex: -3, layout: [.header]),
                    .init(sectionIndex: .init(sections.first!), viewType: ReusableView.self, zIndex: -2, layout: [.footer]),
                    .init(sectionIndex: .init(sections.first!),
                          viewType: ReusableView.self,
                          zIndex: 2,
                          layout: [.cells],
                          insets: .init(top: 50, left: 50, bottom: 50, right: 50)),
                    .init(sectionIndex: .init(sections.first!), viewType: ReusableView.self, zIndex: -1, layout: [.cells])
                )
            case .fix_insets:
                defaultPluginModes = [.fixSupplementaryViewInset(.all)]
                sectionView.set(pluginModes: defaultPluginModes)
                sectionView.reloadData()
            case .no_fix_insets:
                defaultPluginModes = []
                sectionView.set(pluginModes: [])
                sectionView.reloadData()
            case .all:
                update(.init(sectionIndex: .all, viewType: ReusableView.self))
            case .add:
                update(.init(sectionIndex: .init(sections.first!), viewType: ReusableView.self))
            case .add_header:
                update(.init(sectionIndex: .init(sections.first!), viewType: ReusableView.self, layout: [.header]))
            case .add_cells:
                update(.init(sectionIndex: .init(sections.first!), viewType: ReusableView.self, layout: [.cells]))
            case .add_footer:
                update(.init(sectionIndex: .init(sections.first!), viewType: ReusableView.self, layout: [.footer]))
            case .add_c_f:
                update(.init(sectionIndex: .init(sections.first!), viewType: ReusableView.self, layout: [.cells, .footer]))
            case .add_h_c:
                update(.init(sectionIndex: .init(sections.first!), viewType: ReusableView.self, layout: [.header, .cells]))
            case .inset_10:
                update(.init(sectionIndex: .init(sections.first!),
                             viewType: ReusableView.self,
                             insets: .init(top: 10, left: 10, bottom: 10, right: 10)))
            case .inset_40:
                update(.init(sectionIndex: .init(sections.first!),
                             viewType: ReusableView.self,
                             insets: .init(top: 40, left: 40, bottom: 40, right: 40)))
            }
        }
        
        func update(_ decoration: SectionCollectionFlowLayout.Decoration...) {
            sectionView.set(pluginModes: defaultPluginModes + [.decorations(decoration)])
            sectionView.reloadData()
        }
        
        func animate(_ event: @escaping () -> Void) {
            isAnimating = true
            Gcd.delay(.main, seconds: 0.5) {
                self.isAnimating = false
                event()
            }
        }
        
        func setupUI() {
            sections.forEach { section in
                section.sectionInset = .init(top: 20, left: 8, bottom: 20, right: 8)
                section.minimumLineSpacing = 8
            }
            manager.update(sections)
        }
        
    }
    
}
