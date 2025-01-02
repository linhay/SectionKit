//
//  04-LoadAndPull.swift
//  Example
//
//  Created by linhey on 1/2/25.
//

import SwiftUI
import SectionUI

/**
 # 加载更多数据 / 重置数据
 */

struct LoadAndPullView: View {
    let colors = [UIColor.red, .green, .blue, .yellow, .orange]
    @State
    var refreshableTime = 0
    @State
    var section = TextCell
        .wrapperToSingleTypeSection()
    
    var body: some View {
        SKUIController {
            SKCollectionViewController()
                .reload(section)
                .refreshable {
                    refreshableTime = 0
                    section
                        .setHeader(TextReusableView.self,
                                   model: .init(text: "header - \(refreshableTime)",
                                                color: .purple))
                        .config(models: (0...1).map({ idx in
                            TextCell.Model(text: "第 \(refreshableTime) 批数据",
                                           color: colors[idx % colors.count])
                        }))
                }
        }
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            Button {
                refreshableTime += 1
                section
                    .setHeader(TextReusableView.self,
                               model: .init(text: "header - \(refreshableTime)",
                                            color: .purple))
                    .append((0...1).map({ idx in
                        TextCell.Model(text: "第 \(refreshableTime) 批数据",
                                       color: colors[idx % colors.count])
                    }))
            } label: {
                Text("点击加载更多")
                    .padding()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
            }
        }
    }
    
}

#Preview {
    LoadAndPullView()
}
