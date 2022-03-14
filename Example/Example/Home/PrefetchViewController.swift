//
//  PrefetchViewController.swift
//  Example
//
//  Created by linhey on 2022/3/13.
//

import UIKit
import SectionKit
import Stem

class PrefetchViewController: SectionCollectionViewController {
    
    let section = SingleTypeSection<ColorBlockCell>()
    
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
        section.config(models: section.models + (0...20).map({ index in
                .init(color: color,
                      text: (section.models.count + index).description,
                      size: .init(width: view.frame.width, height: 44))
        }))
    }
    
    func bindUI() {
        section.prefetchEvent.delegate(on: self) { (self, rows) in
            guard let max = rows.max(), max >= self.section.models.count - 1 else {
                print("prefetch: data loaded \(rows.map(\.description).joined(separator: ","))")
                return
            }
            print("prefetch: \(rows.map(\.description).joined(separator: ","))")
            self.next()
        }
    }
    
    func setupUI() {
        section.sectionInset = .init(top: 20, left: 20, bottom: 0, right: 20)
        section.minimumLineSpacing = 8
        manager.update(section)
    }
    
}
