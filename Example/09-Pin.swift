//
//  07-Decoration.swift
//  Example
//
//  Created by linhey on 1/3/25.
//

import SectionUI
import SwiftUI
import Combine

/**
 装饰视图
 */

@Observable
class PinIndexReducer {
     var cancellables = Set<AnyCancellable>()

}

struct PinIndexView: View {
    
    @State var frame: CGRect = .zero
    @State var contentOffset: CGPoint = .zero
    @State var index: IndexPath = .init(row: 0, section: 0)
    @State private var store = PinIndexReducer()

    var body: some View {
        SKUIController {
            let colors = [UIColor.red, .green, .blue, .yellow, .orange]
            let section1 = ColorCell
                .wrapperToSingleTypeSection((0...10).map({ idx in
                        .init(text: idx.description, color: colors[idx % colors.count], alignment: .left)
                }))
                .cellSafeSize(.default, transforms: .fixed(height: 44))
                .setHeader(TextReusableView.self, model: .init(text: " Header 1", color: .clear))
                .setFooter(TextReusableView.self, model: .init(text: " Footer 1", color: .clear))
            
            let section2 = ColorCell
                .wrapperToSingleTypeSection((0...10).map({ idx in
                        .init(text: idx.description, color: colors[idx % colors.count], alignment: .right)
                }))
                .cellSafeSize(.default, transforms: .fixed(height: 44))
                .setHeader(TextReusableView.self, model: .init(text: " Header 2", color: .clear))
                .setFooter(TextReusableView.self, model: .init(text: " Footer 2", color: .clear))
            
            let section3 = ColorCell
                .wrapperToSingleTypeSection((0...100).map({ idx in
                        .init(text: idx.description, color: colors[idx % colors.count])
                }))
                .cellSafeSize(.default, transforms: .fixed(height: 44))
                .setHeader(TextReusableView.self, model: .init(text: "Header 3", color: .clear))
                .setFooter(TextReusableView.self, model: .init(text: "Footer 3", color: .clear))
            
            let controller = SKCollectionViewController()
                .reloadSections([section1, section2, section3])
            
//            let layout = TestCollectionViewFlowLayout()
//            layout.sectionHeadersPinToVisibleBounds = true
//            controller.sectionView.setCollectionViewLayout(layout, animated: false)
            section1.pinCell(at: 9, options: { options in
                options.padding = 44
            }).store(in: &store.cancellables)
            section2.pinCell(at: 2, options: { options in
                options.padding = 44 * 2
            }).store(in: &store.cancellables)
            section3.pinCell(at: 5, options: { options in
                options.padding = 44 * 3
            }).store(in: &store.cancellables)

            section1.pinHeader().store(in: &store.cancellables)
            section2.pinHeader().store(in: &store.cancellables)
            section3.pinHeader().store(in: &store.cancellables)
            
            section1.pinFooter().store(in: &store.cancellables)
            section2.pinFooter().store(in: &store.cancellables)
            section3.pinFooter().store(in: &store.cancellables)
            
            controller.manager.reload()
            return controller
        }
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            VStack(alignment: .leading) {
                Text("index: \(index.description)")
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text("frame: \(frame.debugDescription)")
                Text("offset: \(contentOffset.y)")
            }
            .padding()
            .background(.ultraThinMaterial)
        }
    }
}

#Preview {
    PinIndexView()
}
