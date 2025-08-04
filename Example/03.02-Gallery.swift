//
//  03.01-Gallery.swift
//  Example
//
//  Created by linhey on 6/16/25.
//

import SwiftUI
import SectionUI

@Observable
class GalleryReducer {
    
    @ObservationIgnored var models = (0...20000).map { idx in
        let colors = [UIColor.red, .green, .blue, .yellow, .orange]
        return ColorCell.Model.init(text: idx.description, color: colors[idx % colors.count].withAlphaComponent(0.5))
    }
    
    @ObservationIgnored var layout = TestCollectionViewFlowLayout()
    @ObservationIgnored var controller = GridViewController()
    @ObservationIgnored var sectionController = SKCollectionViewController()
    @ObservationIgnored var section = ColorCell
        .wrapperToSingleTypeSection()
        .setSectionStyle { section in
            section.minimumLineSpacing = 1
            section.minimumInteritemSpacing = 1
            section.feature.skipDisplayEventWhenFullyRefreshed = true
        }
        .cellSafeSize(.fraction(0.25), transforms: .height(asRatioOfWidth: 1))
    
    
    func reload() {
        let sections = SKPerformance.shared.duration {
            models.map({ model in
                ColorCell.wrapperToSingleTypeSection(model)
            })
        }
        SKPerformance.shared.duration {
            sectionController.reloadSections(sections)
        }
//        models = SKPerformance.shared.duration {
//             models.reversed()
//        }
//        controller.reload(model: models)
//        SKPerformance.shared.duration {
//            section.config(models: models)
//        }
    }
    
}

struct GalleryView: View {
    
    @State var store: GalleryReducer
    
    var body: some View {
        VStack {
            SKUIController {
                store.sectionController
//                SKCollectionViewController()
//                    .reloadSections(store.section)
//                    .sectionViewStyle { view in
//                        view.setCollectionViewLayout(store.layout, animated: true)
//                    }
            }
            
            Button("reload") {
                store.reload()
            }
        }
    }
    
}

import UIKit

class GridViewController: UIViewController {

    var collectionView: UICollectionView!
    var section = ColorCell
        .wrapperToSingleTypeSection()
        .setSectionStyle { section in
            section.minimumLineSpacing = 1
            section.minimumInteritemSpacing = 1
            section.feature.skipDisplayEventWhenFullyRefreshed = true
        }
        .cellSafeSize(.fraction(0.25), transforms: .height(asRatioOfWidth: 1))
    
    
    func reload(model: [ColorCell.Model]) {
        section.config(models: model)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupCollectionView()
    }

    private func setupCollectionView() {
        let layout = createGridLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self

        // 注册通用 Cell，具体样式由你自己实现
        section.sectionInjection = SKCSectionInjection(index: 0, sectionView: SKCSectionViewProvider(collectionView, manager: nil))
//        section.sectionInjection?.add(kind: .reload) { injection, action in
//            injection.sectionView?.reloadData()
//        }
        section.config(sectionView: collectionView)

        // 注册 header（可选）
//        collectionView.register(UICollectionReusableView.self,
//                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//                                withReuseIdentifier: "Header")

        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func createGridLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, environment in
            let spacing: CGFloat = 2
            let itemsPerRow: CGFloat = 3
            let itemFraction = 1.0 / itemsPerRow

            // Item
            let itemSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(itemFraction),
                heightDimension: .fractionalWidth(itemFraction)
            )
            let item = NSCollectionLayoutItem(layoutSize: itemSize)
            item.contentInsets = NSDirectionalEdgeInsets(top: spacing / 2, leading: spacing / 2, bottom: spacing / 2, trailing: spacing / 2)

            // Group
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalWidth(itemFraction)
            )
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

            // Section
            let section = NSCollectionLayoutSection(group: group)

            // Header (optional)
            let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                    heightDimension: .absolute(44))
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            section.boundarySupplementaryItems = [header]

            return section
        }
    }
}

// MARK: - UICollectionViewDataSource

extension GridViewController: UICollectionViewDataSource {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1 // 可修改
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.section.itemCount
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return section.item(at: indexPath.item)
    }

//    func collectionView(_ collectionView: UICollectionView,
//                        viewForSupplementaryElementOfKind kind: String,
//                        at indexPath: IndexPath) -> UICollectionReusableView {
//        return collectionView.dequeueReusableSupplementaryView(ofKind: kind,
//                                                               withReuseIdentifier: "Header",
//                                                               for: indexPath)
//    }
}

// MARK: - UICollectionViewDelegate

extension GridViewController: UICollectionViewDelegate {
    // Add interactions if needed
}

#Preview {
    @Previewable @State var store = GalleryReducer()
    GalleryView(store: store)
}
