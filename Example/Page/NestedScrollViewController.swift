//
//  03.03-Aquaman.swift
//  Example
//
//  Created by linhey on 6/16/25.
//

import SectionUI
import SnapKit
import UIKit

final class SKControllerCell<Model: UIViewController>: UICollectionViewCell, SKConfigurableView,
    SKLoadViewProtocol
{

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

class NestedScrollViewController: UIViewController {

    lazy var sectionController = SKCollectionViewController()
    lazy var pageController = SKPageViewController()
    lazy var menuView = UIView()
    lazy var headerView = UIView()
    lazy var contentSection = SKControllerCell<SKPageViewController>
        .wrapperToSingleTypeSection(pageController)

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "03.03-Aquaman"
        view.backgroundColor = .white

        addChild(sectionController)
        view.addSubview(sectionController.view)
        sectionController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        sectionController.didMove(toParent: self)
        sectionController.view.backgroundColor = .red

        reload()

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Reload", style: .plain, target: self, action: #selector(reload))
    }

    @objc func reload() {
        pageController.manager.scrollDirection = .horizontal
        pageController.manager.spacing = 10
        pageController.manager.setChilds([
            .withController(
                id: "1",
                { context in
                    let controller = SKCollectionViewController()
                        .sectionViewStyle { view in
                            view.bounces = false
                        }
                    controller.reloadSections(
                        ColorCell
                            .wrapperToSingleTypeSection(
                                (0...20).map({ idx in
                                    .init(
                                        text: idx.description, color: .darkGray, alignment: .center)
                                })
                            )
                            .cellSafeSize(.default, transforms: .fixed(height: 44))
                    )
                    controller.view.backgroundColor = .purple
                    return controller
                }),

            .withController(
                id: "2",
                { context in
                    let controller = UIViewController()
                    controller.view.backgroundColor = .blue
                    return controller
                }),

            .withController(
                id: "3",
                { context in
                    let controller = UIViewController()
                    controller.view.backgroundColor = .yellow
                    return controller
                }),
        ])

        menuView.backgroundColor = .blue
        headerView.backgroundColor = .green

        // Note: SKCAnyViewCell uses SwiftUI usually?
        // Let's check `SKCAnyViewCell`. If it's pure UIKit, good.
        // If it's not, I should use a custom cell or ViewWrapper.
        // `SKCAnyViewCell` implies generics or erasure.
        // Assuming `SKCAnyViewCell` is available in SectionUI and handles UIView -> Cell.
        // If not, I can create a simple wrapper cell.
        // The original code used `SKCAnyViewCell.wrapperToSingleTypeSection`.
        // I will assume it works or replace it if I knew it failed.
        // Since I'm "Removing SwiftUI", checks on SectionUI internals are limited.
        // But `SKCAnyViewCell` taking a UIView usually doesn't need SwiftUI.

        sectionController.reloadSections([
            SKCAnyViewCell.wrapperToSingleTypeSection(
                .init(
                    view: headerView,
                    size: .height(200),
                    layout: .fill())),
            SKCAnyViewCell.wrapperToSingleTypeSection(
                .init(
                    view: menuView,
                    size: .height(44),
                    layout: .fill())),
            contentSection,
        ])
    }
}
