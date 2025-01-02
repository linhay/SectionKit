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
                .frame(maxWidth: .infinity, alignment: .leading)
                NavigationLink("02-MultipleSection") {
                    MultipleSectionView()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                NavigationLink("03-FooterAndHeaderView") {
                    FooterAndHeaderView()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                NavigationLink("04-LoadAndPullView") {
                    LoadAndPullView()
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .font(.title3)
            .fontWeight(.medium)
        }
    }
}

#Preview {
    ContentView()
}
