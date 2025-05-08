//
//  10-Page.swift
//  Example
//
//  Created by linhey on 5/8/25.
//

import SwiftUI
import SectionUI

struct PageView: View {
    
    @State private var selection: Int = 0
    
    var body: some View {
        SKUIController {
            let controller = SKCollectionViewController()
            let section = TextCell
                .wrapperToSingleTypeSection((0...100).map({ idx in
                        .init(text: idx.description,
                              color: [UIColor.red, .green, .blue, .yellow, .orange][idx % 5],
                              height: nil)
                }))
            controller.reloadSections(section)
            controller.sectionView.bounces = false
            controller.view.backgroundColor = .blue
            controller.sectionView.contentInsetAdjustmentBehavior = .never
            controller.sectionView.isPagingEnabled = true
            controller.sectionView.snp.makeConstraints { make in
                make.top.equalToSuperview()
            }
            controller.manager.scrollObserver.add { handle in
                handle.onChanged { scrollView in
                    let index = Int(scrollView.contentOffset.y / scrollView.bounds.height)
                    if index != selection {
                        selection = index
                    }
                }
            }
            controller.manager.scroll(to: 0, row: 10, animated: false)
            return controller
        }
        .overlay(alignment: .topLeading) {
            Text(selection.description)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .safeAreaPadding()
        }
    }
    
}

#Preview {
    PageView()
        .ignoresSafeArea()
}
