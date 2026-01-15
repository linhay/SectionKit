//
//  11-Page2.swift
//  Example
//
//  Created by linhey on 5/8/25.
//

import Combine
import SectionUI
import SnapKit
import UIKit

private class Page2ChildController: UIViewController {

    let index: Int

    init(index: Int) {
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        print("Page2ChildController \(index) deinit")
    }

    private lazy var label: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18, weight: .regular)
        view.textColor = .white
        view.textAlignment = .center
        view.backgroundColor = .black
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor =
            [
                UIColor.red,
                .green,
                .blue,
                .yellow,
                .orange,
            ][index % 5]
        label.text = "\(index)"
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
    }
}

class PageViewController: SKPageViewController {

    private let indicatorLabel = UILabel()
    private var selection: Int = 0 {
        didSet {
            indicatorLabel.text = "\(selection)"
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "11-Page2"
        view.backgroundColor = .white

        manager.spacing = 12
        manager.$selection.removeDuplicates().dropFirst().sink { [weak self] idx in
            self?.selection = idx
        }.store(in: &cancellables)

        manager.setChilds(
            (0...50).map({ idx in
                .init(id: "\(idx)") { content in
                    Page2ChildController(index: content.index)
                }
            }))

        // Indicator
        indicatorLabel.font = .systemFont(ofSize: 20, weight: .bold)
        indicatorLabel.textColor = .black
        indicatorLabel.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        indicatorLabel.layer.cornerRadius = 20
        indicatorLabel.layer.masksToBounds = true
        indicatorLabel.textAlignment = .center
        indicatorLabel.text = "0"
        view.addSubview(indicatorLabel)
        indicatorLabel.snp.makeConstraints { make in
            make.leading.top.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.width.height.equalTo(40)
        }
    }
}
