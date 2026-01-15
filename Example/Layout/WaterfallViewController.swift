//
//  03.04-Waterfall.swift
//  Example
//
//  Created by linhey on 6/16/25.
//

import SectionUI
import SnapKit
import UIKit

final class WaterfallCell: UICollectionViewCell, SKConfigurableView, SKLoadViewProtocol {

    typealias Model = CGFloat
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return .init(width: size.width, height: model ?? 44)
    }

    func config(_ model: Model) {
        label.text = String(format: "%.0f", model)
    }

    private lazy var label: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18, weight: .regular)
        view.textColor = .black
        view.textAlignment = .center
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        contentView.backgroundColor = .lightGray
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 4
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class WaterfallViewController: UIViewController {

    lazy var layout = SKWaterfallLayout()
        .columnWidth(equalParts: 2)

    lazy var sectionController = SKCollectionViewController()

    lazy var section1 =
        WaterfallCell
        .wrapperToSingleTypeSection()
        .cellSafeSize(.fraction(0.5))
        .setSectionStyle([\.minimumLineSpacing, \.minimumInteritemSpacing], 12)
        .setSectionStyle(\.sectionInset, .init(top: 8, left: 8, bottom: 8, right: 8))
        .setHeader(TextReusableView.self, model: .init(text: "Header 1", color: .green))
        .setFooter(TextReusableView.self, model: .init(text: "Footer 1", color: .green))

    lazy var section2 =
        WaterfallCell
        .wrapperToSingleTypeSection()
        .cellSafeSize(.fraction(0.5))
        .setSectionStyle([\.minimumLineSpacing, \.minimumInteritemSpacing], 12)
        .setSectionStyle(\.sectionInset, .init(top: 8, left: 8, bottom: 8, right: 8))
        .setHeader(TextReusableView.self, model: .init(text: "Header 2", color: .green))
        .setFooter(TextReusableView.self, model: .init(text: "Footer 2", color: .green))

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "03.04-Waterfall"
        view.backgroundColor = .white

        addChild(sectionController)
        view.addSubview(sectionController.view)
        sectionController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        sectionController.didMove(toParent: self)

        // Setup layout
        sectionController.sectionView.collectionViewLayout = layout

        // Reload Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Reload", style: .plain, target: self, action: #selector(reload))

        reload()
    }

    @objc func reload() {
        let models = (0...100)
            .map({ _ in CGFloat(Int.random(in: 44...200)) })
        section1.config(models: models)
        section2.config(models: models)
        sectionController.reloadSections([section1, section2])
    }
}
