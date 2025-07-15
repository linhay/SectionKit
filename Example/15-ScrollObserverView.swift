//
//  14-SKAdaptiveView.swift
//  Example
//
//  Created by linhey on 5/19/25.
//

import SwiftUI
import SectionUI

/**
 # ContentOffset 监听
 - 往 manager.scrollObserver 里添加监听
 - tips: 可以配置自定义 UIScrollViewDelegate
 ```swift
 controller.manager.scrollObserver.add(any UIScrollViewDelegate)
 ```
 */
struct ScrollObserverView: View {
    
    let colors = [UIColor.red, .green, .blue, .yellow, .orange]
    
    @State var controller = SKCollectionViewController().ignoresSafeArea()
    @State var section = TextCell
        .wrapperToSingleTypeSection((0...40).map({ idx in
            TextCell.Model(text: "第 1 组, 第 \(idx) 行", color: .red)
        }))
    @State var contentOffsetY = 0.0
    
    var body: some View {
        SKUIController {
            controller
                .reloadSections(section)
            
            controller.manager.scrollObserver
                .add(scroll: "observer") { handle in
                    handle.onChanged { scrollView in
                        contentOffsetY = scrollView.contentOffset.y
                    }
                }
            return controller
        }
        .ignoresSafeArea()
        .onAppear {
            if let section = controller.manager.sections.last {
                controller.manager.scroll(to: section, row: section.itemCount - 1, at: .bottom, animated: false)
            }
        }
        .overlay(alignment: .top) {
            Text("\(contentOffsetY.description)")
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
        }
        .overlay(alignment: .bottom) {
            HStack {
                Button("To Bottom") {
                    section.scrollToBottom(animated: true)
                }
                .foregroundStyle(.white)
                .padding()
                .background {
                    Capsule()
                        .fill(Color.black)
                }
                Button("To Top") {
                    section.scrollToTop(animated: true)
                }
                .foregroundStyle(.white)
                .padding()
                .background {
                    Capsule()
                        .fill(Color.black)
                }
            }
            .padding()
        }
    }
    
}

#Preview {
    ScrollObserverView()
}
