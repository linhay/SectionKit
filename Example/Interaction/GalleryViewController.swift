//
//  03.02-Gallery.swift
//  Example
//
//  Created by linhey on 6/16/25.
//

import SectionUI
import SnapKit
import UIKit

class GalleryViewController: UIViewController {

    var models = (0...20000).map { idx in
        let colors = [UIColor.red, .green, .blue, .yellow, .orange]
        return ColorCell.Model.init(
            text: idx.description, color: colors[idx % colors.count].withAlphaComponent(0.5))
    }

    lazy var sectionController = SKCollectionViewController()
    lazy var section =
        ColorCell
        .wrapperToSingleTypeSection()
        .setSectionStyle { section in
            section.minimumLineSpacing = 1
            section.minimumInteritemSpacing = 1
            section.feature.skipDisplayEventWhenFullyRefreshed = true
        }
        .cellSafeSize(.fraction(0.25), transforms: .height(asRatioOfWidth: 1))

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "03.02-Gallery"
        view.backgroundColor = .white

        addChild(sectionController)
        view.addSubview(sectionController.view)
        sectionController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        sectionController.didMove(toParent: self)

        // Reload Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Reload", style: .plain, target: self, action: #selector(reload))

        reload()
    }

    @objc func reload() {
        let sections = SKPerformance.shared.duration {
            models.map({ model in
                ColorCell.wrapperToSingleTypeSection(model)
            })
        }

        SKPerformance.shared.duration {
            // Note: In original code it created 'sections' (plural) from models?
            // Original: models.map({ ColorCell.wrapperToSingleTypeSection(model) })
            // This creates 20000 sections? Yes.
            // And then reloads sections.
            // My implementation above was: `section.config(models: ...)`?
            // Original used `SKCollectionViewController.reloadSections(sections)`.
            // So it was creating many sections. I should preserve that logic if it's for performance testing.

            sectionController.reloadSections(sections)
        }
    }
}
