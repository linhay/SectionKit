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

struct PinIndexView: View {
    
    @State var frame: CGRect = .zero
    @State var contentOffset: CGPoint = .zero
    @State var index: IndexPath = .init(row: 0, section: 0)
    
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
            
            section1.pin(cell: 9, manager: controller.manager)
            section2.pin(cell: 2, manager: controller.manager)
            section3.pin(cell: 5, manager: controller.manager)

            section1.pin(header: controller.manager)
            section2.pin(header: controller.manager)
            section3.pin(header: controller.manager)
            
            section1.pin(footer: controller.manager)
            section2.pin(footer: controller.manager)
            section3.pin(footer: controller.manager)
            
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
