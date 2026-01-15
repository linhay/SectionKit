//
//  03.01-Parallax.swift
//  Example
//
//  Created by linhey on 5/27/25.
//

import Combine
import SectionUI
import SnapKit
import UIKit

class ParallaxCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {

    struct Model {
        let idx: Int
        var contentOffset: SKPublishedValue<CGFloat>
        let imageName: String
        weak var container: UIView?
    }

    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        .init(width: size.width - 40, height: size.height)
    }

    private var model: Model?
    private var cancellable: AnyCancellable?

    func config(_ model: Model) {
        self.model = model
        imageView.image = UIImage(named: model.imageName)
        label.text = model.imageName
        cancellable = model.contentOffset.bind { [weak self] offset in
            guard let self = self else { return }
            updateParallax()
        }
    }

    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()

    private lazy var label: UILabel = {
        let view = UILabel()
        view.numberOfLines = 0
        view.backgroundColor = .white.withAlphaComponent(0.5)
        view.font = .systemFont(ofSize: 18, weight: .regular)
        view.layer.cornerRadius = 8
        view.textColor = .black
        view.layer.masksToBounds = true
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        contentView.layer.cornerRadius = 20
        contentView.layer.borderColor = UIColor.white.cgColor
        contentView.layer.borderWidth = 4
        contentView.layer.masksToBounds = true
        contentView.addSubview(imageView)
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.left.bottom.equalToSuperview().inset(20)
            make.width.equalTo(160)
            make.height.equalTo(56)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateParallax()
    }

    // 图片的视差范围（可以调整）
    func updateParallax() {
        guard let model = model,
            let image = UIImage(named: model.imageName),
            let container = model.container,
            let superview = self.superview
        else {
            return
        }

        // 计算 imageView 的实际尺寸（保持图片比例）
        let width = bounds.height / image.size.height * image.size.width
        let size = CGSize(width: width, height: bounds.height)
        let parallaxOffset: CGFloat = (size.width - bounds.width) / 2
        imageView.frame.size = size

        // 计算 cell 相对于 container 的中心偏移
        let cellCenterInContainer = superview.convert(center, to: container)
        let distanceFromCenter = cellCenterInContainer.x - container.bounds.midX
        let normalizedOffset = distanceFromCenter / container.bounds.width  // 范围大致在 [-1, 1]

        // 计算最大可偏移
        let maxOffsetX = max((imageView.frame.width - bounds.width) / 2, 0)
        let offsetX = normalizedOffset * parallaxOffset
        let clampedOffsetX = max(min(offsetX, maxOffsetX), -maxOffsetX)

        // 应用偏移
        imageView.frame.origin.x = (bounds.width - imageView.frame.width) / 2 + clampedOffsetX

        // Debug Label
        label.text = [
            "  idx: \(model.idx)",
            "  distance: \(Int(distanceFromCenter))",
        ].joined(separator: "\n")
    }

}

class ParallaxViewController: UIViewController {

    @SKPublished var contentOffset: CGFloat = 0
    private let skController = SKCollectionViewController()
    private let layout = CenteredCollectionViewFlowLayout()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "03.01 - 视差交互示例"

        // Gradient Setup
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.blue.cgColor, UIColor.red.cgColor, UIColor.purple.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = view.bounds
        view.layer.addSublayer(gradientLayer)

        addChild(skController)
        view.addSubview(skController.view)
        skController.didMove(toParent: self)
        skController.view.backgroundColor = .clear

        skController.view.snp.makeConstraints { make in
            make.leading.trailing.centerY.equalToSuperview()
            make.height.equalTo(400)
        }

        layout.scrollDirection = .horizontal
        skController.sectionView.collectionViewLayout = layout

        skController.manager.scrollObserver.add { [weak self] handle in
            handle.onChanged { scrollView in
                self?.contentOffset = scrollView.contentOffset.x
            }
        }

        // Models
        let models = (0...100).map { idx in
            let name = "image\(idx % 2)"
            return ParallaxCell.Model(
                idx: idx,
                contentOffset: $contentOffset,
                imageName: name,
                container: skController.view)
        }

        let section =
            ParallaxCell
            .wrapperToSingleTypeSection(models)
            .setSectionStyle([\.minimumLineSpacing, \.minimumInteritemSpacing], 20)
            .setSectionStyle(\.sectionInset, .init(top: 0, left: 20, bottom: 0, right: 20))

        skController.manager.reload(section)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.sublayers?.first?.frame = view.bounds
    }
}
