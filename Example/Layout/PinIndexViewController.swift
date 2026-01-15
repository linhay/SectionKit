//
//  02.03-Pin-any-view.swift
//  Example
//
//  Created by linhey on 1/3/25.
//

import Combine
import SectionUI
import SnapKit
import UIKit

class PinIndexViewController: SKCollectionViewController {

    var cancellables = Set<AnyCancellable>()

    lazy var section1 =
        ColorCell
        .wrapperToSingleTypeSection(
            (0...10).map({ idx in
                .init(text: idx.description, color: .clear, alignment: .left)
            })
        )
        .cellSafeSize(.default, transforms: .fixed(height: 44))
        .setHeader(
            TextReusableView.self,
            model: .init(text: " Header 1", color: .clear, alignment: .center)
        )
        .setFooter(
            TextReusableView.self, model: .init(text: " Footer 1", color: .clear, alignment: .right)
        )
        .setSectionStyle(\.sectionInset, .init(top: 8, left: 0, bottom: 0, right: 0))
        .setAttributes(.reverseFooterAndSectionInset)
        .setAttributes(.reverseHeaderAndSectionInset)

    lazy var section2 =
        ColorCell
        .wrapperToSingleTypeSection(
            (0...10).map({ idx in
                .init(text: idx.description, color: .clear, alignment: .left)
            })
        )
        .cellSafeSize(.default, transforms: .fixed(height: 44))
        .setHeader(
            TextReusableView.self,
            model: .init(text: " Header 2", color: .clear, alignment: .center)
        )
        .setFooter(
            TextReusableView.self, model: .init(text: " Footer 2", color: .clear, alignment: .right)
        )
        .setSectionStyle(\.sectionInset, .init(top: 8, left: 0, bottom: 0, right: 0))
        .setAttributes(.reverseFooterAndSectionInset)
        .setAttributes(.reverseHeaderAndSectionInset)

    lazy var section3 =
        ColorCell
        .wrapperToSingleTypeSection(
            (0...100).map({ idx in
                .init(text: idx.description, color: .clear, alignment: .left)
            })
        )
        .cellSafeSize(.default, transforms: .fixed(height: 44))
        .setHeader(
            TextReusableView.self, model: .init(text: "Header 3", color: .clear, alignment: .center)
        )
        .setFooter(
            TextReusableView.self, model: .init(text: "Footer 3", color: .clear, alignment: .right)
        )
        .setSectionStyle(\.sectionInset, .init(top: 8, left: 0, bottom: 0, right: 0))
        .setAttributes(.reverseFooterAndSectionInset)
        .setAttributes(.reverseHeaderAndSectionInset)

    lazy var rule1 = RuleView(color: .black, text: "cell-5:")
    lazy var rule2 = RuleView(color: .orange, text: "footer:")  // yellow in swiftui, use orange for visibility
    lazy var rule3 = RuleView(color: .blue, text: "header:")

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "09-PinIndex"

        // Gradient Background
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.systemPink.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 0, y: 1)
        gradientLayer.frame = view.bounds
        let bgView = UIView(frame: view.bounds)
        bgView.layer.addSublayer(gradientLayer)
        sectionView.backgroundView = bgView

        // Add Rules
        let stack = UIStackView(arrangedSubviews: [rule1, rule2, rule3])
        stack.axis = .horizontal
        stack.spacing = 0
        stack.alignment = .top
        stack.distribution = .fillEqually
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview().inset(16)
            make.height.equalTo(400)  // loose constraint
        }

        manager.reload([section1, section2, section3])

        setupBindings()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let bg = sectionView.backgroundView?.layer.sublayers?.first as? CAGradientLayer {
            bg.frame = sectionView.bounds
        }
    }

    func setupBindings() {
        section1.pinCell(at: 5) { options in
            options.$distance.receive(on: RunLoop.main).sink { [weak self] value in
                self?.rule1.update(value: value)
            }.store(in: &self.cancellables)
        }.store(in: &cancellables)

        section2.pinFooter { options in
            options.$distance.receive(on: RunLoop.main).sink { [weak self] value in
                self?.rule2.update(value: value)
            }.store(in: &self.cancellables)
        }.store(in: &cancellables)

        section3.pinHeader { options in
            options.$distance.receive(on: RunLoop.main).sink { [weak self] value in
                self?.rule3.update(value: value)
            }.store(in: &self.cancellables)
        }.store(in: &cancellables)
    }
}

class RuleView: UIView {

    private let color: UIColor
    private let text: String
    private let label = UILabel()
    private let bar = UIView()
    private let topRect = UIView()
    private let bottomRect = UIView()

    init(color: UIColor, text: String) {
        self.color = color
        self.text = text
        super.init(frame: .zero)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setupUI() {
        addSubview(topRect)
        addSubview(bar)
        addSubview(bottomRect)
        addSubview(label)

        topRect.backgroundColor = color
        bar.backgroundColor = color
        bottomRect.backgroundColor = color

        label.text = text
        label.font = .monospacedSystemFont(ofSize: 12, weight: .regular)
        label.backgroundColor = UIColor.white.withAlphaComponent(0.8)

        topRect.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.width.equalTo(32)
            make.height.equalTo(4)
        }

        bar.snp.makeConstraints { make in
            make.top.equalTo(topRect.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalTo(1)
            make.bottom.equalTo(bottomRect.snp.top)
        }

        bottomRect.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.width.equalTo(32)
            make.height.equalTo(4)
            make.bottom.equalToSuperview()  // Initially 0 height
        }

        label.snp.makeConstraints { make in
            make.center.equalTo(bar)
        }

        isHidden = true
    }

    func update(value: CGFloat?) {
        guard let value = value else {
            isHidden = true
            return
        }
        isHidden = false
        label.text = "\(text) \(Int(value))"

        // Update height constraint of self to match value
        // Note: The stack view alignment is .top, so changing intrinsic content size or constraints is needed.
        // But here we are inside a stack.
        // Actually the value is the height of the rule.

        self.snp.remakeConstraints { make in
            make.height.equalTo(value).priority(.high)
        }
    }
}
