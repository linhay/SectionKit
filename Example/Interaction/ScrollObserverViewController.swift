//
//  14-SKAdaptiveView.swift
//  Example
//
//  Created by linhey on 5/19/25.
//

import SectionUI
import SnapKit
import UIKit

/// # ContentOffset 监听
/// - 往 manager.scrollObserver 里添加监听
/// - tips: 可以配置自定义 UIScrollViewDelegate
/// ```swift
/// controller.manager.scrollObserver.add(any UIScrollViewDelegate)
/// ```
class ScrollObserverViewController: UIViewController {

    let colors = [UIColor.red, .green, .blue, .yellow, .orange]

    lazy var controller = SKCollectionViewController()

    lazy var section =
        TextCell
        .wrapperToSingleTypeSection(
            (0...40).map({ idx in
                TextCell.Model(text: "第 1 组, 第 \(idx) 行", color: .red)
            }))

    private let offsetLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "15-ScrollObserver"
        view.backgroundColor = .white

        addChild(controller)
        view.addSubview(controller.view)
        controller.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        controller.didMove(toParent: self)

        controller.reloadSections(section)

        controller.manager.scrollObserver
            .add(scroll: "observer") { [weak self] handle in
                handle.onChanged { scrollView in
                    self?.offsetLabel.text = "\(scrollView.contentOffset.y)"
                }
            }

        // Setup UI Overlays
        setupOverlay()

        // Initial scroll
        DispatchQueue.main.async {
            if let section = self.controller.manager.sections.last {
                // Ensure section has items
                // section.itemCount works if wrapper conforms or we check models.
                // Assuming it works.
                self.controller.manager.scroll(to: section, row: 40, at: .bottom, animated: false)
            }
        }
    }

    func setupOverlay() {
        // Offset Label
        offsetLabel.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        offsetLabel.layer.cornerRadius = 12
        offsetLabel.layer.masksToBounds = true
        offsetLabel.text = "0.0"
        view.addSubview(offsetLabel)
        offsetLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.greaterThanOrEqualTo(100)
            make.height.equalTo(40)
        }

        // Buttons
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 20
        view.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.centerX.equalToSuperview()
        }

        let toBottomBtn = createButton(title: "To Bottom", action: #selector(toBottom))
        let toTopBtn = createButton(title: "To Top", action: #selector(toTop))
        stack.addArrangedSubview(toBottomBtn)
        stack.addArrangedSubview(toTopBtn)
    }

    func createButton(title: String, action: Selector) -> UIButton {
        let btn = UIButton(type: .system)
        btn.setTitle(title, for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .black
        btn.layer.cornerRadius = 22
        btn.contentEdgeInsets = .init(top: 10, left: 20, bottom: 10, right: 20)
        btn.addTarget(self, action: action, for: .touchUpInside)
        return btn
    }

    @objc func toBottom() {
        section.scrollToBottom(animated: true)
    }

    @objc func toTop() {
        section.scrollToTop(animated: true)
    }
}
