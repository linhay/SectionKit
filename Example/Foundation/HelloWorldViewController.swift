//
//  01-IntroductionView.swift
//  Example
//
//  Created by linhey on 1/2/25.
//

import SectionUI
import SnapKit
import UIKit

/**
 # 单一类型 & 单组视图

 ## 创建 Cell
 1. 遵守并实现 SKLoadViewProtocol, SKConfigurableView 协议
 2. [必选] 实现 preferredSize 方法, 返回 cell 的大小
 3. [必选] 实现 config 方法, 用于配置 cell 的数据

 ## 从 Cell 创建一个 section
 1. [可选] 在 section 中添加 cell 的生命周期方法来完成业务需求

 ## 绑定 section 到 UICollectionView
 > 这里我使用便捷的 SKCollectionViewController 作为 UICollectionView 的代理
 1. controller.reload(section)

 ## 配置 section 的数据
 1. section.config(models: [Model])

 以上步骤即可完成一个简单的 Section 的配置
*/

class IntroductionCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {

    struct Model {
        let text: String
        let color: UIColor
    }

    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return .init(width: size.width, height: 44)
    }

    func config(_ model: Model) {
        titleLabel.text = model.text
        descLabel.text = nil
        descLabel.isHidden = true
        contentView.backgroundColor = model.color
    }

    func desc(_ string: String) {
        descLabel.text = string
        descLabel.isHidden = false
    }

    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18, weight: .regular)
        view.textColor = .black
        view.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        return view
    }()

    private lazy var descLabel: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18, weight: .regular)
        view.textColor = .black.withAlphaComponent(0.6)
        view.snp.makeConstraints { make in
            make.height.equalTo(20)
        }
        return view
    }()

    private lazy var hStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [titleLabel, descLabel])
        view.spacing = 12
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .center
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(hStackView)
        hStackView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class HelloWorldViewController: SKCollectionViewController {

    let colors = [UIColor.red, .green, .blue, .yellow, .orange]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "01-Introduction"
        view.backgroundColor = .white

        let section =
            IntroductionCell
            .wrapperToSingleTypeSection()
            .onCellAction(.willDisplay) { context in
                context.view().desc("willDisplay")
            }
            .onCellAction(.didEndDisplay) { context in
                context.view().desc("didEndDisplay")
            }
            .onCellAction(.selected) { context in
                context.view().desc("selected")
            }
            .onCellAction(.deselected) { context in
                context.view().desc("deselected")
            }

        section.config(
            models: (0...100).map({ idx in
                IntroductionCell.Model(text: "第 \(idx) 行", color: colors[idx % colors.count])
            }))

        manager.reload(section)
    }
}
