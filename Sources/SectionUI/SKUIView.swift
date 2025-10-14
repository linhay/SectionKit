//
//  File.swift
//  SectionKit
//
//  Created by linhey on 1/3/25.
//

import UIKit
import SwiftUI

public extension SKWrapper where Base: UIView {
    
    static func toSwiftUI(make: @escaping SKUIView<Base>.MakeAction,
                          update: @escaping SKUIView<Base>.UpdateAction = { _, _ in }) -> SKUIView<Base> {
        SKUIView(make: make, update: update)
    }
    
}

public struct SKUIView<View: UIView>: UIViewRepresentable {
    
    public typealias UIViewType = View
    public typealias MakeAction   = (_ context: Context) -> View
    public typealias UpdateAction = (_ view: View, _ context: Context) -> Void
    
    public let make: MakeAction
    public let update: UpdateAction
    
    public init(make: @escaping MakeAction,
                update: @escaping UpdateAction = { _, _ in }) {
        self.make = make
        self.update = update
    }
    
    public func makeUIView(context: Context) -> View {
        make(context)
    }
    
    public func updateUIView(_ uiView: View, context: Context) {
        update(uiView, context)
    }
    
}
