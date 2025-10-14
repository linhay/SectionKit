//
//  SwiftUIController.swift
//  CoolUp
//
//  Created by linhey on 12/13/24.
//

import UIKit
import SwiftUI

public extension SKWrapper where Base: UIViewController {
    
    static func toSwiftUI(make: @escaping SKUIController<Base>.MakeAction,
                          update: @escaping SKUIController<Base>.UpdateAction = { _, _ in }) -> SKUIController<Base> {
        SKUIController(make: make, update: update)
    }
    
}


public struct SKUIController<Controller: UIViewController>: UIViewControllerRepresentable {
    
    public typealias UIViewControllerType = Controller
    public typealias MakeAction   = () -> Controller
    public typealias UpdateAction = (_ controller: Controller, _ context: Context) -> Void
    
    public let make: MakeAction
    public let update: UpdateAction
    
    public init(make: @escaping MakeAction,
                update: @escaping UpdateAction = { _, _ in }) {
        self.make = make
        self.update = update
    }
    
    public func makeUIViewController(context: Context) -> Controller {
        make()
    }
    
    public func updateUIViewController(_ uiViewController: Controller, context: Context) {
        update(uiViewController, context)
    }
    
}
