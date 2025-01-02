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
            VStack {
                NavigationLink("introduction") {
                    IntroductionView()
                }
                NavigationLink("multipleSection") {
                    IntroductionView()
                }
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
