//
//  File.swift
//
//
//  Created by linhey on 2022/5/5.
//

import SectionUI
import Stem
#if canImport(UIKit)
import UIKit

class DecorationViewController: SKCollectionViewController {
    enum Action: String, CaseIterable {
        case fix_insets
        case no_fix_insets
        case add
        case all_vis
        case all_section
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

extension DecorationViewController {
    class LeftViewController: SKCollectionViewController {
        
        let section = StringRawCell<Action>.wrapperToSingleTypeSection(Action.allCases)
        lazy var skmanager = SKCManager(sectionView: sectionView)
        
        override func viewDidLoad() {
            super.viewDidLoad()
            setupUI()
        }
        
        func setupUI() {
            section.sectionInset = .init(top: 20, left: 8, bottom: 0, right: 8)
            section.minimumLineSpacing = 8
            skmanager.reload([section])
        }
    }
}

extension DecorationViewController {
    class RightViewController: SKCollectionViewController {
        let size = CGSize(width: 88, height: 44)
        lazy var skmanager = SKCManager(sectionView: sectionView)
        
        lazy var sections = (0 ... 10).map { sectionIndex in
            ColorBlockCell
                .wrapperToSingleTypeSection((0 ... 10).map { index in
                        .init(color: .red, text: "\(sectionIndex - index)", size: size)
                })
                .set(supplementary: .init(kind: .header, type: ReusableView.self, model: "header - \(sectionIndex)"))
//                .set(supplementary: .init(kind: .footer, type: ReusableView.self, model: "footer - \(sectionIndex)"))
        }
        
        var isAnimating = false
        var defaultPluginModes: [SKCollectionFlowLayout.PluginMode] = [.fixSupplementaryViewInset(.all)]
        
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
            case .all_vis:
                update(.init(sectionIndex: .all, viewType: ReusableView.self, modes: [.visibleView, .sectionInsetPaddingWhen([.header, .footer])]))
            case .all_section:
                update(.init(sectionIndex: .all, viewType: ReusableView.self, modes: [.section, .sectionInsetPaddingWhen([.header, .footer])]))
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
                             modes: [.section],
                             insets: .init(top: 40, left: 40, bottom: 40, right: 40)))
            }
        }
        
        func update(_ decoration: SKCollectionFlowLayout.Decoration...) {
            sectionView.set(pluginModes: [.decorations(decoration)] + defaultPluginModes)
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
            skmanager.reload(sections)
        }
    }
}

#endif
