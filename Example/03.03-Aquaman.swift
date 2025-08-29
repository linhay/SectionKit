//
//  03.01-Gallery.swift
//  Example
//
//  Created by linhey on 6/16/25.
//

import SwiftUI
import SectionUI
import UIKit

final class SKControllerCell<Model: UIViewController>: UICollectionViewCell, SKConfigurableView, SKLoadViewProtocol {
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return size
    }

    func config(_ model: Model) {
        contentView.subviews.forEach({ $0.removeFromSuperview() })
        contentView.addSubview(model.view)
        model.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.layoutIfNeeded()
    }
}



@Observable
class AquamanReducer {
    
    @ObservationIgnored var sectionController = SKCollectionViewController()
    @ObservationIgnored var pageController = SKPageViewController()
    @ObservationIgnored lazy var menuView = UIView()
    @ObservationIgnored lazy var headerView = UIView()
    @ObservationIgnored lazy var contentSection = SKControllerCell<SKPageViewController>
        .wrapperToSingleTypeSection(pageController)
    
    func contentController() -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .white
        return controller
    }
    
    func reload() {
        pageController.manager.scrollDirection = .horizontal
        pageController.manager.spacing = 10
        pageController.manager.childs = [
            .withController({ context in
                let controller = SKCollectionViewController()
                    .sectionViewStyle { view in
                        view.bounces = false
                    }
                controller.reloadSections(
                    ColorCell
                        .wrapperToSingleTypeSection((0...20).map({ idx in
                        .init(text: idx.description, color: .darkGray, alignment: .center)
                }))
                        .cellSafeSize(.default, transforms: .fixed(height: 44))
                )
                controller.view.backgroundColor = .purple
                return controller
            }),
            
                .withController({ context in
                    let controller = UIViewController()
                    controller.view.backgroundColor = .blue
                    return controller
                }),
            
                .withController({ context in
                    let controller = UIViewController()
                    controller.view.backgroundColor = .yellow
                    return controller
                }),
        ]
        
        menuView.backgroundColor = .blue
        headerView.backgroundColor = .green
        sectionController.reloadSections([
            SKCAnyViewCell.wrapperToSingleTypeSection(.init(view: headerView,
                                                            size: .height(200),
                                                            layout: .fill())),
            SKCAnyViewCell.wrapperToSingleTypeSection(.init(view: menuView,
                                                            size: .height(44),
                                                            layout: .fill())),
            contentSection
        ])
    }
    
}

struct AquamanView: View {
    
    @State var store: AquamanReducer
    
    var body: some View {
        VStack {
            SKUIController {
                store
                    .sectionController
                    .backgroundColor(.red)
            }
            .ignoresSafeArea()
            Button("reload") {
                store.reload()
            }
        }
        .task {
            store.reload()
        }
    }
    
}

#Preview {
    @Previewable @State var store = AquamanReducer()
    AquamanView(store: store)
}
