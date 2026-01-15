//
//  14-SKAdaptiveView.swift
//  Example
//
//  Created by linhey on 5/19/25.
//

import SectionUI
import SnapKit
import UIKit

/// # Cell 自动高度
/// ## 让 Cell 遵守 `SKConfigurableAdaptiveMainView` 协议即可
/// - SKConfigurableAdaptiveMainView 是 `SKConfigurableView` 的高级变体, 底层使用 `UIView.systemLayoutSizeFitting` 来自动计算高度.
/// - tips: 可以进一步搭配高度缓存工具来来提升性能.
/// ```swift
/// SKAdaptiveCell
///     .wrapperToSingleTypeSection()
///     .highPerformanceID(by: \.model)
/// ```
final class SKAdaptiveCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableAdaptiveMainView
{

    static let adaptive = SpecializedAdaptive()
    typealias Model = String

    private lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear

        contentView.addSubview(containerView)
        containerView.addSubview(label)

        containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(4)
            make.leading.trailing.equalToSuperview()
        }

        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func config(_ model: Model) {
        label.text = model
    }

}

class AdaptiveCellViewController: SKCollectionViewController {

    lazy var section =
        SKAdaptiveCell
        .wrapperToSingleTypeSection()
        .highPerformanceID(by: \.model)

    let models = [
        "2025-05-19T10:38:54+0800 error codes.vapor.application : error=RedisConnectionPoolError(baseError: RediStack.RedisConnectionPoolError.BaseError.poolClosed) [Queues] Job run failed",
        "Suite CompanyInformationJobTest passed after 556.816 seconds.",
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "14-SKAdaptiveCell"
        view.backgroundColor = .white

        section.config(models: models.shuffled())
        manager.reload(section)

        let btn = UIButton(type: .system)
        btn.setTitle("reload", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .black
        btn.layer.cornerRadius = 22  // Capsule roughly
        btn.addTarget(self, action: #selector(reload), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(100)
            make.height.equalTo(44)
        }
    }

    @objc func reload() {
        section.config(models: models.shuffled())
        section.reload()
    }
}
