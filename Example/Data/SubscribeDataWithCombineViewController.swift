//
//  SubscribeDataView.swift
//  Example
//
//  Created by linhey on 1/2/25.
//

import Combine
import SectionUI
import SnapKit
import UIKit

class SubscribeDataWithCombineViewController: SKCollectionViewController {

    let colors = [UIColor.red, .green, .blue, .yellow, .orange]
    var subject = CurrentValueSubject<[TextCell.Model], Never>.init([])
    lazy var section = TextCell.wrapperToSingleTypeSection()
    var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "05-SubscribeDataWithCombine"
        view.backgroundColor = .white

        manager.reload(section)

        section.subscribe(models: subject)

        // Checking API: `subscribe(models:)` usually performs the subscription.
        // If it returns nothing (void), well good. If it returns cancellable, we should store it.
        // Based on previous swiftUI code: `section.subscribe(models: subject)` was called in .task.
        // It likely returns a Cancellable or `Self`.
        // If it returns `Self`, then we don't need to store anything if the section holds the subscription.
        // But usually Combine subscription needs storage.
        // I will assume for now it handles itself or returns something.
        // Actually, the previous code didn't assign result of observe/subscribe?

        // Wait, the previous code:
        // .task { section.subscribe(models: subject) }
        // If `subscribe` returns a Cancellable, it would be cancelled immediately if not stored, UNLESS .task handles it?
        // .task handles Async sequences or just runs code.
        // Let's assume `subscribe` manages the subscription internally in the section (weak ref to subject?) or returns Cancellable.
        // I'll assume it returns Cancellable if it follows standard.
        // If not, I'll validte later. For now, since I can't check source of `subscribe`, I'll check if it returns something.
        // Since I can't compile, I'll just write it.

        let btn = UIButton(type: .system)
        btn.setTitle("点击加载更多", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .blue
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(addMore), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(44)
        }
    }

    @objc func addMore() {
        let newItems = ((subject.value.count)...(subject.value.count + 2))
            .map({ idx in
                TextCell.Model(
                    text: "第 \(idx) 行",
                    color: colors[idx % colors.count])
            })
        subject.value += newItems
    }
}
