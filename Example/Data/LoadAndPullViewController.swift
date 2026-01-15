//
//  04-LoadAndPull.swift
//  Example
//
//  Created by linhey on 1/2/25.
//

import SectionUI
import SnapKit
import UIKit

/**
 # 加载更多数据 / 重置数据
 */

class LoadAndPullViewController: SKCollectionViewController {

    let colors = [UIColor.red, .green, .blue, .yellow, .orange]
    var refreshableTime = 0
    lazy var section = TextCell.wrapperToSingleTypeSection()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "04-LoadAndPull"
        view.backgroundColor = .white

        manager.reload(section)

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        sectionView.refreshControl = refreshControl

        // Initial load logic if needed

        // Load More Button
        let btn = UIButton(type: .system)
        btn.setTitle("点击加载更多", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .blue
        btn.layer.cornerRadius = 8
        btn.addTarget(self, action: #selector(loadMore), for: .touchUpInside)
        view.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(200)
            make.height.equalTo(44)
        }
    }

    @objc func refresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.refreshableTime = 0
            self.section
                .setHeader(
                    TextReusableView.self,
                    model: .init(
                        text: "header - \(self.refreshableTime)",
                        color: .purple)
                )
                .config(
                    models: (0...1).map({ idx in
                        TextCell.Model(
                            text: "第 \(self.refreshableTime) 批数据",
                            color: self.colors[idx % self.colors.count])
                    }))
            self.section.reload()
            self.sectionView.refreshControl?.endRefreshing()
        }
    }

    @objc func loadMore() {
        refreshableTime += 1
        section
            .setHeader(
                TextReusableView.self,
                model: .init(
                    text: "header - \(refreshableTime)",
                    color: .purple)
            )
            .append(
                (0...1).map({ idx in
                    TextCell.Model(
                        text: "第 \(refreshableTime) 批数据",
                        color: colors[idx % colors.count])
                }))
    }
}
