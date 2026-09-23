//
//  01-02-Rendering-list-with-single-type-section.swift
//  Example
//
//  Created by linhey on 5/20/25.
//

import SectionUI
import UIKit

/**
 # 使用 SKCSingleTypeSection 渲染单类型列表
 > SKCSingleTypeSection 是一个单一类型的 Section, 适用于渲染单类型的列表.
 1. 从 DemoCell 开始创建 SKCSingleTypeSection<DemoCell>
 ``` swift
 /// 以下写法是等价的
 let section1 = SKCSingleTypeSection<DemoCell>()
 let section2 = DemoCell.wrapperToSingleTypeSection()
 ```

 2. 配置 Section
 ``` swift
 /// 以下写法是等价的
 let section1 = SKCSingleTypeSection<DemoCell>()
 section1.minimumLineSpacing = 10
 section1.minimumLineSpacing = 10
 section1.minimumInteritemSpacing = 10
 section1.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)

 let section2 = DemoCell
    .wrapperToSingleTypeSection()
    .setSectionStyle { section in
        section.minimumLineSpacing = 10
        section.minimumLineSpacing = 10
        section.minimumInteritemSpacing = 10
        section.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
    }
    .setCellStyle { context in
        /// 配置 Cell
    }
    .onCellAction(.selected) { context in
     /// 处理 Cell 的选中事件
    }
    .onCellAction(.willDisplay) { context in
     /// 处理 Cell 的即将显示事件
    }
    .onCellAction(.didEndDisplay) { context in
     /// 处理 Cell 的结束显示事件
    }
 ```
*/

class SingleTypeSectionViewController: SKCollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "01.02-SingleTypeSection"
        view.backgroundColor = .white

        let section =
            DemoCell
            .wrapperToSingleTypeSection([.blue, .green, .red, .yellow])
            .setSectionStyle { section in
                section.minimumLineSpacing = 10
                section.minimumInteritemSpacing = 10
                section.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
            }
            .setCellStyle { context in
                // context.view, context.row, context.model, context.section
            }
            .onCellAction(.selected) { context in
                /// 处理 Cell 的选中事件
                context.view().contentView.backgroundColor = UIColor.purple
            }
            .onCellAction(.willDisplay) { context in
                /// 处理 Cell 的即将显示事件
            }
            .onCellAction(.didEndDisplay) { context in
                /// 处理 Cell 的结束显示事件
            }

        manager.reload(section)
    }
}

private class DemoCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    typealias Model = UIColor

    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        .init(width: 100, height: 100)
    }

    func config(_ model: Model) {
        contentView.backgroundColor = model
    }

}
