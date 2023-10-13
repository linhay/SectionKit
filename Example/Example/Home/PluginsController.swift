//
//  PluginsController.swift
//  Example
//
//  Created by linhey on 2023/10/13.
//

import SectionUI
import Delegate
import Foundation

class PluginsController: SKCollectionViewController {
    
    private let toolbar = PluginsToolbarController()
    var action = PluginsToolbarController.Action.none
    var enable = false
    override func viewDidLoad() {
        super.viewDidLoad()
        st.addChilds(toolbar)
        view.addSubview(toolbar.view)
        toolbar.view.snp.makeConstraints { make in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(300)
        }
        sectionView.snp.makeConstraints { make in
            make.bottom.equalTo(toolbar.view.snp.top)
        }
        sectionView.backgroundColor = .gray
        toolbar.sectionView.backgroundColor = .darkGray
        toolbar.event.delegate(on: self) { (self, action) in
            self.sectionView.set(pluginModes: [])
            switch action {
            case .left:
                let section = ColorBlockCell
                    .wrapperToSingleTypeSection((0...9).map({
                        .init(color: .red,
                              text: $0.description,
                              size: .init(width: 77, height: 50))
                    }))
                self.manager.reload(section)
                self.plugin(modes: .left)
            case .centerX:
                let section = ColorBlockCell
                    .wrapperToSingleTypeSection((0...9).map({
                        .init(color: .red,
                              text: $0.description,
                              size: .init(width: 77, height: 50))
                    }))
                self.manager.reload(section)
                self.plugin(modes: .centerX)
            case .fixSupplementaryViewInsetVertical:
                let section = ColorBlockCell
                    .wrapperToSingleTypeSection((0...9).map({
                        .init(color: .red,
                              text: $0.description,
                              size: .init(width: 77, height: 50))
                    }))
                    .setSectionStyle({ section in
                        section.sectionInset = .init(top: 10, left: 0, bottom: 20, right: 0)
                    })
                    .set(supplementary: .header, type: ReusableView.self, model: "header")
                    .set(supplementary: .footer, type: ReusableView.self, model: "footer")
                self.manager.reload(section)
                self.plugin(modes: .fixSupplementaryViewInset(.vertical))
            case .fixSupplementaryViewSize:
                let section = ColorBlockCell
                    .wrapperToSingleTypeSection((0...9).map({
                        .init(color: .red,
                              text: $0.description,
                              size: .init(width: 77, height: 50))
                    }))
                    .setSectionStyle({ section in
                        section.sectionInset = .init(top: 10, left: 0, bottom: 20, right: 0)
                    })
                    .set(supplementary: .header, type: ReusableView.self, model: .init(text: "header", size: .init(width: 50, height: 50)))
                    .set(supplementary: .footer, type: ReusableView.self, model: .init(text: "footer", size: .init(width: 50, height: 50)))
                self.manager.reload(section)
                self.plugin(modes: .fixSupplementaryViewSize)
            case .decoration:
                let header = ColorBlockCell
                    .wrapperToSingleTypeSection((0...4).map({
                        .init(color: .red,
                              text: $0.description,
                              size: .init(width: 77, height: 50))
                    }))
                    .setSectionStyle({ section in
                        section.sectionInset = .init(top: 10, left: 0, bottom: 20, right: 0)
                    })
                    .set(supplementary: .header, type: ReusableView.self, model: "header")
                    .set(supplementary: .footer, type: ReusableView.self, model: "footer")
                    .onSupplementaryAction(.willDisplay) { context in
                        if case .custom(_) = context.kind {
                            context.view().backgroundColor = .blue
                        }
                    }
                
                let cells = ColorBlockCell
                    .wrapperToSingleTypeSection((0...4).map({
                        .init(color: .red,
                              text: $0.description,
                              size: .init(width: 77, height: 50))
                    }))
                    .setSectionStyle({ section in
                        section.sectionInset = .init(top: 10, left: 0, bottom: 20, right: 0)
                    })
                    .set(supplementary: .header, type: ReusableView.self, model: "header")
                    .set(supplementary: .footer, type: ReusableView.self, model: "footer")
                    .onSupplementaryAction(.willDisplay) { context in
                        if case .custom(_) = context.kind {
                            context.view().backgroundColor = .blue
                        }
                    }
                
                let footer = ColorBlockCell
                    .wrapperToSingleTypeSection((0...4).map({
                        .init(color: .red,
                              text: $0.description,
                              size: .init(width: 77, height: 50))
                    }))
                    .setSectionStyle({ section in
                        section.sectionInset = .init(top: 10, left: 0, bottom: 20, right: 0)
                    })
                    .set(supplementary: .header, type: ReusableView.self, model: "header")
                    .set(supplementary: .footer, type: ReusableView.self, model: "footer")
                    .onSupplementaryAction(.willDisplay) { context in
                        if case .custom(_) = context.kind {
                            context.view().backgroundColor = .blue
                        }
                    }
                
                self.manager.reload([header, cells, footer])
                self.plugin(modes: .decorations([
                    .init(header, viewType: ReusableView.self, layout: [.header]),
                    .init(cells, viewType: ReusableView.self, layout: [.header, .cells]),
                    .init(footer, viewType: ReusableView.self, layout: [.cells, .footer]),
                ]))
            case .sectionHeadersPinToVisibleBounds:
                let sections: [SKCBaseSectionProtocol] = (0...10).map { idx in
                   return ColorBlockCell
                        .wrapperToSingleTypeSection((0...4).map({ _ in
                            ColorBlockCell.Model(color: .red, text: idx.description, size: .init(width: 77, height: 50))
                        }))
                        .setSectionStyle({ section in
                            section.sectionInset = .init(top: 10, left: 0, bottom: 20, right: 0)
                        })
                        .set(supplementary: .header, type: ReusableView.self, model: "header \(idx)")
                        .set(supplementary: .footer, type: ReusableView.self, model: "footer")
                }
                self.manager.reload(sections)
                self.plugin(modes: .sectionHeadersPinToVisibleBounds([.init(sections[2])]))
            case .none:
                break
            }
        }
    }
    
    func plugin(modes: SKCLayoutPlugins.Mode...) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            self.sectionView.set(pluginModes: modes)
            self.manager.reload()
        })
    }
}

class PluginsToolbarController: SKCollectionViewController {
    
    enum Action: String, CaseIterable {
        case none
        case left
        case centerX
        case fixSupplementaryViewInsetVertical
        case fixSupplementaryViewSize
        case decoration
        case sectionHeadersPinToVisibleBounds
    }
    
    let event = Delegate<Action, Void>()
    lazy var section = StringRawCell
        .wrapperToSingleTypeSection(Action.allCases.filter({ $0 != .none }))
        .onCellAction(.selected) { context in
            self.event.call(context.model)
        }
        .setSectionStyle { section in
            section.minimumLineSpacing = 8
            section.sectionInset = .init(top: 0, left: 20, bottom: 0, right: 20)
        }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        manager.reload(section)
    }
    
}
