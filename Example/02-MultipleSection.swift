//
//  02-MultipleSection.swift
//  Example
//
//  Created by linhey on 1/2/25.
//

import SwiftUI
import SectionUI

/**
 # 多组视图
 */

struct MultipleSectionView: View {
    
    let colors = [UIColor.red, .green, .blue, .yellow, .orange]

    @State
    var section1 = TextCell
        .wrapperToSingleTypeSection()
        .onCellAction(.willDisplay) { context in
            context.view().desc(context.type.description)
        }
        .onCellAction(.didEndDisplay) { context in
            context.view().desc(context.type.description)
        }
        .onCellAction(.selected) { context in
            context.view().desc(context.type.description)
        }
        .onCellAction(.deselected) { context in
            context.view().desc(context.type.description)
        }
    
    @State
    var section2 = TextCell
        .wrapperToSingleTypeSection()
        .setSectionStyle(\.sectionInset, UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0))
        .onCellAction(.willDisplay) { context in
            context.view().desc(context.type.description)
        }
        .onCellAction(.didEndDisplay) { context in
            context.view().desc(context.type.description)
        }
        .onCellAction(.selected) { context in
            context.view().desc(context.type.description)
        }
        .onCellAction(.deselected) { context in
            context.view().desc(context.type.description)
        }
    
    var body: some View {
        SKPreview.sections {
            [section1, section2]
        }.onAppear {
            section1.config(models: (0...4).map({ idx in
                TextCell.Model(text: "第 1 组, 第 \(idx) 行", color: colors[idx % colors.count])
            }))
            section2.config(models: (0...4).map({ idx in
                TextCell.Model(text: "第 2 组, 第 \(idx) 行", color: colors[idx % colors.count])
            }))
        }
        .ignoresSafeArea()
    }
    
}

#Preview {
    MultipleSectionView()
}
