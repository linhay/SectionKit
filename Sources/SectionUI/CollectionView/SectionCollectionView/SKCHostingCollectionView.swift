//
//  SKHostingCollectionView.swift
//  CoolUp
//
//  Created by linhey on 11/15/24.
//

import Foundation
import SwiftUI
import SectionKit

public struct SKCHostingCollectionView: UIViewRepresentable {
   
    public typealias UIViewType = SKCollectionView
    
    public class Coordinator {
        public var manager: SKCManager?
        public var sections: [SKCAnySectionProtocol]
        
        init(manager: SKCManager? = nil, sections: [SKCAnySectionProtocol]) {
            self.manager = manager
            self.sections = sections
        }
    }
        
    let sections: [any SKCAnySectionProtocol]
    
    public init(_ sections: [any SKCAnySectionProtocol]) {
        self.sections = sections
    }

    public init(@SectionArrayResultBuilder<SKCAnySectionProtocol> builder: () -> [SKCAnySectionProtocol]) {
        self.sections = builder()
    }
    
    public func makeCoordinator() -> Coordinator {
        .init(manager: nil, sections: sections)
    }
    
    public func makeUIView(context: Context) -> SKCollectionView {
        let view = SKCollectionView()
        context.coordinator.manager = view.manager
        context.coordinator.manager?.reload(context.coordinator.sections.map(\.section))
        return view
    }
    
    public func updateUIView(_ uiView: SKCollectionView, context: Context) {
        context.coordinator.manager?.reload(context.coordinator.sections.map(\.section))
    }
}
