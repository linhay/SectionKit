//
//  ContentView.swift
//  Example
//
//  Created by linhey on 1/2/25.
//

import SwiftUI

struct ContentView: View {
    
    func Link(_ title: String, desc: String, @ViewBuilder destination: () -> some View) -> some View {
        NavigationLink(destination: destination) {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.medium)
                Text(desc)
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("01-Introduction") {
                    IntroductionView()
                }
                NavigationLink("02-MultipleSection") {
                    MultipleSectionView()
                }
                NavigationLink("03-FooterAndHeaderView") {
                    FooterAndHeaderView()
                }
                NavigationLink("04-LoadAndPullView") {
                    LoadAndPullView()
                }
                NavigationLink("05-SubscribeDataWithCombine") {
                    SubscribeDataWithCombineView()
                }
                NavigationLink("06-Grid") {
                    GridColorView()
                }
                NavigationLink("07-Decoration") {
                    DecorationView()
                }
                NavigationLink("09-PinIndex") {
                    PinIndexView()
                }
                NavigationLink("10-Page") {
                    PageView()
                }
                NavigationLink("11-Page2") {
                    Page2View()
                }
                NavigationLink("12-SKPublished") {
                    SKPublishedView()
                }
                NavigationLink("13-SKPublishedCell") {
                    SKPublishedViewCellView()
                }
                Link("14 - Cell自动高度", desc: "SKConfigurableAdaptiveMainView 示例") {
                    SKAdaptiveCellView()
                }
                Link("15 - ContentOffset 监听", desc: "manager.scrollObserver 示例") {
                    ScrollObserverView()
                }
            }
            .font(.title3)
            .fontWeight(.medium)
        }
    }
}

#Preview {
    ContentView()
}
