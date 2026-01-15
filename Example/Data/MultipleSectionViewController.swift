//
//  02-MultipleSection.swift
//  Example
//
//  Created by linhey on 1/2/25.
//

import SectionUI
import SnapKit
import UIKit

/**
 # 多组视图
 */

class MultipleSectionViewController: SKCollectionViewController {

    let colors = [UIColor.red, .green, .blue, .yellow, .orange]

    lazy var section1 =
        TextCell
        .wrapperToSingleTypeSection()
        .setSectionStyle({ section in
            section.reloadKind = .difference()
        })
        .onCellAction(.willDisplay) { context in
            context.view().desc(context.type.description)
        }
        .onCellAction(.didEndDisplay) { context in
            context.view().desc(context.type.description)
        }
        .onCellAction(.selected) { context in
            context.view().desc(context.type.description)
        }
        .onCellAction(.deselected) { context in
            context.view().desc(context.type.description)
        }

    lazy var section2 =
        TextCell
        .wrapperToSingleTypeSection()
        .setSectionStyle(\.sectionInset, UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        .onCellAction(.willDisplay) { context in
            context.view().desc(context.type.description)
        }
        .onCellAction(.didEndDisplay) { context in
            context.view().desc(context.type.description)
        }
        .onCellAction(.selected) { context in
            context.view().desc(context.type.description)
        }
        .onCellAction(.deselected) { context in
            context.view().desc(context.type.description)
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "02-MultipleSection"
        view.backgroundColor = .white

        section1.config(
            models: (0...4).map({ idx in
                TextCell.Model(text: "第 1 组, 第 \(idx) 行", color: colors[idx % colors.count])
            }))
        section2.config(
            models: (0...4).map({ idx in
                TextCell.Model(text: "第 2 组, 第 \(idx) 行", color: colors[idx % colors.count])
            }))

        manager.reload([section1, section2])

        let btn = UIButton(type: .system)
        btn.setTitle("Diff Shuffle", for: .normal)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 8
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.black.cgColor
        btn.addTarget(self, action: #selector(shuffle), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(120)
            make.height.equalTo(44)
        }
    }

    @objc func shuffle() {
        section1.config(
            models: (0...4).map({ idx in
                TextCell.Model(text: "第 1 组, 第 \(idx) 行", color: colors[idx % colors.count])
            }).shuffled())
    }
}
