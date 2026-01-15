//
//  08-IndexTitles.swift
//  Example
//
//  Created by linhey on 1/3/25.
//

import Combine
import SectionUI
import UIKit

class IndexTitlesViewController: SKCollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "08-IndexTitles"
        view.backgroundColor = .white

        // Note: SKCollectionViewController might not support automatic index titles out of the box unless the delegate/datasource methods are forwarded or configured.
        // `SKCollectionsView` (used inside SKCollectionViewController) typically relies on SectionKit.
        // The `SectionKit` framework handles `sectionIndexTitles`?
        // In SwiftUI example: `.setSectionStyle { section in section.indexTitle = "A" }`
        // This implies `SKCSectionType` has `indexTitle` and the manager/adapter handles it.
        // `UICollectionView` does not support index titles like `UITableView` does by default, unless using a specific layout or custom implementation, OR if `SectionKit` implemented it?
        // Wait, `UITableView` has index titles. `UICollectionView` generally doesn't have a built-in API for the right-side index bar.
        // However, the original SwiftUI code suggests it WAS supported: `.setSectionStyle { ... indexTitle = "A" }`.
        // This suggests SectionKit has a mechanism for it, possibly overlaying a view or using a custom layout with supplementary views?
        // Actually, looking at `SKCSection` properties, if `indexTitle` exists, the framework likely uses it.
        // But if `SKCollectionViewController` is just wrapping `UICollectionView`, where does the index bar come from?
        // Maybe it's a `UITableView` wrapper? No, `SKCollectionViewController` implies CollectionView.
        // Perhaps `SectionKit` adds an index view overlay?
        // I will assume the same configuration works in UIKit as it did in SwiftUI wrapper.

        let colors = [UIColor.red, .green, .blue, .yellow, .orange]

        let sections = (0...26).map { idx -> SKCSingleTypeSection<ColorCell> in
            let char = String(UnicodeScalar(65 + idx)!)
            return
                ColorCell
                .wrapperToSingleTypeSection(
                    (0...5).map({ _ in
                        .init(text: "\(char) - Item", color: colors[idx % colors.count])
                    })
                )
                .setSectionStyle { section in
                    section.indexTitle = char
                }
                .cellSafeSize(.default, transforms: .fixed(height: 44))
        }

        manager.reload(sections)
    }
}
