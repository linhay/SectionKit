//
//  06-Grid.swift
//  Example
//
//  Created by linhey on 1/2/25.
//

import Combine
import SectionUI
import UIKit

/**
    网格布局
    1. 可以使用 cellSafeSize(_ kind: SKSafeSizeProviderKind, transforms: SKSafeSizeTransform) 来约束 Cell - preferredSize(limit size: CGSize, model: Model?) -> CGSize 函数中 size 的大小
    2. 也可以使用 Cell - preferredSize(limit size: CGSize, model: Model?) -> CGSize 直接返回 size 来实现
 */

class GridColorViewController: SKCollectionViewController {

    let colors = [UIColor.red, .green, .blue, .yellow, .orange]
    lazy var section =
        ColorCell
        .wrapperToSingleTypeSection()
        .setSectionStyle { section in
            section.minimumLineSpacing = 1
            section.minimumInteritemSpacing = 1
        }
        .cellSafeSize(.fraction(0.25), transforms: .height(asRatioOfWidth: 1))

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "06-Grid"
        view.backgroundColor = .white

        section.config(
            models: (0...50).map({ idx in
                .init(text: idx.description, color: colors[idx % colors.count])
            }))

        manager.reload(section)
    }
}
