//
//  03-FooterAndHeader.swift
//  Example
//
//  Created by linhey on 1/2/25.
//

/**
 # 配置 Footer 和 Header

 */

import SectionUI
import UIKit

class FooterAndHeaderViewController: SKCollectionViewController {

    let colors = [UIColor.red, .green, .blue, .yellow, .orange]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "01.03-FooterAndHeader"
        view.backgroundColor = .white

        let section =
            TextCell
            .wrapperToSingleTypeSection(
                (0...4).map({ idx in
                    TextCell.Model(text: "第 1 组, 第 \(idx) 行", color: colors[idx % colors.count])
                })
            )
            .setHeader(TextReusableView.self, model: .init(text: "Header", color: .green))
            .setFooter(TextReusableView.self, model: .init(text: "Footer", color: .green))

        manager.reload(section)
    }
}
