//
//  03.01-Parallax.swift
//  Example
//
//  Created by linhey on 5/27/25.
//

import SwiftUI
import UIKit
import SectionUI
import Combine

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
              let superview = self.superview else {
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
        let normalizedOffset = distanceFromCenter / container.bounds.width // 范围大致在 [-1, 1]

        // 计算最大可偏移
        let maxOffsetX = max((imageView.frame.width - bounds.width) / 2, 0)
        let offsetX = normalizedOffset * parallaxOffset
        let clampedOffsetX = max(min(offsetX, maxOffsetX), -maxOffsetX)

        // 应用偏移
        imageView.frame.origin.x = (bounds.width - imageView.frame.width) / 2 + clampedOffsetX

        // Debug Label
        label.text = [
            "  idx: \(model.idx)",
            "  distance: \(Int(distanceFromCenter))"
        ].joined(separator: "\n")
    }
    
}

class ParallaxReducer: ObservableObject {
    
    @SKPublished var contentOffset: CGFloat = 0
    weak var container: UIView?
    lazy var models = (0...100).map { idx in
        let name = "image\(idx % 2)"
        return ParallaxCell.Model(idx: idx,
                                  contentOffset: $contentOffset,
                                  imageName: name,
                                  container: container)
    }
    
    lazy var seciton = ParallaxCell
        .wrapperToSingleTypeSection(models)
        .setSectionStyle([\.minimumLineSpacing, \.minimumInteritemSpacing], 20)
        .setSectionStyle(\.sectionInset, .init(top: 0, left: 20, bottom: 0, right: 20))
}

struct ParallaxView: View {
    
    @ObservedObject var store = ParallaxReducer()

    var body: some View {
        ZStack {
            LinearGradient(colors: [
                .blue, .red, .purple
            ], startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
            SKUIController {
                let layout = CenteredCollectionViewFlowLayout()
                layout.scrollDirection = .horizontal

                let controller = SKCollectionViewController()
                    .ignoresSafeArea()
                    .backgroundColor(.clear)
                
                store.container = controller.view
                controller.sectionView.decelerationRate = .fast
                controller.sectionView.collectionViewLayout = layout
                controller.sectionView.scrollDirection = .horizontal
                controller.manager.scrollObserver.add { handle in
                    handle.onChanged { scrollView in
                        store.contentOffset = scrollView.contentOffset.x
                    }
                }
                controller.reloadSections(store.seciton)
                return controller
            }
            .ignoresSafeArea()
            .frame(height: 400)
        }
    }
    
}

#Preview {
    ParallaxView()
}
