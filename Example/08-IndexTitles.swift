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

struct IndexTitlesView: View {

    var body: some View {
        SKPreview.sections {
            let colors = [UIColor.red, .green, .blue, .yellow, .orange]
            return ColorCell
                .wrapperToSingleTypeSection((0...100).map({ idx in
                        .init(text: idx.description, color: colors[idx % colors.count])
                }))
                .setSectionStyle { section in
                    section.indexTitle = "A"
                }
                .cellSafeSize(.default, transforms: .fixed(height: 44))
            
        }
        .ignoresSafeArea()
    }
}

#Preview {
    IndexTitlesView()
}
