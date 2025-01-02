//
//  ContentView.swift
//  Example
//
//  Created by linhey on 1/2/25.
//

import SwiftUI

struct ContentView: View {
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
            }
            .font(.title3)
            .fontWeight(.medium)
        }
    }
}

#Preview {
    ContentView()
}
