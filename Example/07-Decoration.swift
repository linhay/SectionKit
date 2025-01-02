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

struct DecorationView: View {
    @State
    var section = ColorCell
        .wrapperToSingleTypeSection()
        .setSectionStyle { section in
            section.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        }
        .cellSafeSize(.fraction(0.25), transforms: .height(asRatioOfWidth: 1))
        .set(decoration: TextReusableView.self, model: .init(text: "decoration", color: .red)) { decoration in
            decoration.zIndex = 1
            decoration.onAction(.willDisplay) { context in
                context.view.backgroundColor = .red.withAlphaComponent(0.7)
                context.view.titleLabel.font = .systemFont(ofSize: 60, weight: .bold)
            }
        }
    
    var body: some View {
        SKUIController {
            SKCollectionViewController().reload(section)
        }
        .task {
            section.config(models: (0...50).map({ idx in
                    .init(text: idx.description, color: nil)
            }))
        }
        .ignoresSafeArea()
    }
}

#Preview {
    DecorationView()
}
