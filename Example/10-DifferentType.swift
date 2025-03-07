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
 不同类型的视图
 */

struct DifferentTypeView: View {
    
    @State var frame: CGRect = .zero
    @State var contentOffset: CGPoint = .zero
    @State var index: IndexPath = .init(row: 0, section: 0)
    
    var body: some View {
        SKUIController {
            let section = SKCDifferentTypeSection()
                .render {
                    ColorCell
                        .wrapperToDifferentTypeBox([
                            .init(text: "type", color: .blue),
                            .init(text: "type", color: .red),
                            .init(text: "type", color: .yellow)
                        ])
                        .onAction(.selected) { context in
                            print("selected", context.row)
                        }
                    
                    ColorCell
                        .wrapperToDifferentTypeBox(.init(text: "type", color: .red))
                        .onAction(.selected) { context in
                            print("selected", context.row)
                        }
                    
                } header: {
                    TextReusableView
                        .wrapperToDifferentTypeBox(.init(text: "Header", color: .green))
                } footer: {
                    TextReusableView
                        .wrapperToDifferentTypeBox(.init(text: "Footer", color: .green))
                }
                .cellSafeSize(.default, transforms: [.fixed(width: 44), .fixed(height: 44)])
            
            let controller = SKCollectionViewController()
                .reloadSections([section])
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
    DifferentTypeView()
}
