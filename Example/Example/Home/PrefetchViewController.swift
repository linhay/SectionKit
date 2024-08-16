//
//  PrefetchViewController.swift
//  Example
//
//  Created by linhey on 2022/3/13.
//

import Combine
import SectionUI
#if canImport(UIKit)
import UIKit

class PrefetchViewController: SKCollectionViewController {
    private let section = ColorBlockCell
        .wrapperToSingleTypeSection()
        // 首次曝光触发回调
        .model(displayedAt: 1) { context in
            context.model
            context.row
        }
    private var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindUI()
        next()
    }
}

extension PrefetchViewController {
    func next() {
        let color: UIColor = .blue.withAlphaComponent(0.4)
        section.config(models: section.models + (0 ... 20).map { index in
                .init(color: color,
                      text: (section.models.count + index).description,
                      size: .init(width: view.frame.width, height: 44))
        })
    }
    
    func bindUI() {
        section.prefetch.loadMorePublisher
            .sink { [weak self] _ in
                self?.next()
            }.store(in: &cancellables)
    }
    
    func setupUI() {
        section.sectionInset = .init(top: 20, left: 20, bottom: 0, right: 20)
        section.minimumLineSpacing = 8
        manager.reload(section)
    }
}

#endif
