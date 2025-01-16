//
//  SubscribeDataView.swift
//  Example
//
//  Created by linhey on 1/2/25.
//

import SectionUI
import SwiftUI
import Combine

struct SubscribeDataWithCombineView: View {
    let colors = [UIColor.red, .green, .blue, .yellow, .orange]
    @State
    var subject = CurrentValueSubject<[TextCell.Model], Never>.init([])
    @State
    var section = TextCell
        .wrapperToSingleTypeSection()
    
    var body: some View {
        SKPreview.sections {
            section
        }
        .task {
            section.subscribe(models: subject)
        }
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            Button {
                subject.value += ((subject.value.count)...(subject.value.count + 2))
                    .map({ idx in
                        TextCell.Model(text: "第 \(idx) 行",
                                       color: colors[idx % colors.count])
                    })
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
    SubscribeDataWithCombineView()
}
