//
//  PrefetchViewController.swift
//  Example
//
//  Created by linhey on 2022/3/13.
//

import Combine
import SectionKit
import Stem
import UIKit
import StemColor

class PrefetchViewController: SKCollectionViewController {
    private let section = SingleTypeSection<ColorBlockCell>()
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
        let color: UIColor = StemColor.random.alpha(with: 0.4).convert()
        section.config(models: section.models + (0 ... 20).map { index in
            .init(color: color,
                  text: (section.models.count + index).description,
                  size: .init(width: view.frame.width, height: 44))
        })
    }

    func bindUI() {
        section.publishers.prefetch.begin.sink { [weak self] rows in
            guard let self = self else { return }
            guard let max = rows.max(), max >= self.section.models.count - 1 else {
                return
            }
            self.next()
        }.store(in: &cancellables)
    }

    func setupUI() {
        section.sectionInset = .init(top: 20, left: 20, bottom: 0, right: 20)
        section.minimumLineSpacing = 8
        manager.update(section)
    }
}
