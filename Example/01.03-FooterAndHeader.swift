//
//  03-FooterAndHeader.swift
//  Example
//
//  Created by linhey on 1/2/25.
//

/**
 # 配置 Footer 和 Header
 
 */

import SwiftUI
import SectionUI

struct FooterAndHeaderView: View {
    
    let colors = [UIColor.red, .green, .blue, .yellow, .orange]

    @State
    var section = TextCell
        .wrapperToSingleTypeSection()
        .setHeader(TextReusableView.self, model: .init(text: "Header", color: .green))
        .setFooter(TextReusableView.self, model: .init(text: "Footer", color: .green))

    var body: some View {
        SKPreview.sections {
            section
        }.onAppear {
            section.config(models: (0...4).map({ idx in
                TextCell.Model(text: "第 1 组, 第 \(idx) 行", color: colors[idx % colors.count])
            }))
        }
        .ignoresSafeArea()
    }
    
}

#Preview {
    FooterAndHeaderView()
}
