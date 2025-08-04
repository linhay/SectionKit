//
//  ExampleApp.swift
//  Example
//
//  Created by linhey on 1/2/25.
//

import SwiftUI

@main
struct ExampleApp: App {
    @State var store = GalleryReducer()
    var body: some Scene {
        WindowGroup {
            GalleryView(store: store)
        }
    }
}
