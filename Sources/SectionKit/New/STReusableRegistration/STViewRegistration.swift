//
//  STCollectionCellRegistration.swift
//  
//
//  Created by linhey on 2022/8/11.
//

import UIKit

public extension SKConfigurableView where Self: SKLoadViewProtocol {
    
    static func registration(_ model: Model) -> STViewRegistration<Self> {
        return .init(model: model, type: Self.self)
    }
    
    static func registration(_ models: [Model]) -> [STViewRegistration<Self>] {
        return models.map { model in
                .init(model: model, type: Self.self)
        }
    }
    
}

public protocol STViewRegistrationProtocol {
    associatedtype View: SKLoadViewProtocol & SKConfigurableView
    var indexPath: IndexPath? { get set }
    var model: View.Model { get }
    var type: View.Type { get }
}

extension STViewRegistrationProtocol {
    
    func preferredSize(limit size: CGSize) -> CGSize {
        View.preferredSize(limit: size, model: model)
    }
    
}

public class STViewRegistration<View: SKLoadViewProtocol & SKConfigurableView>: STViewRegistrationProtocol {
    
    public var indexPath: IndexPath?
    public let model: View.Model
    public let type: View.Type
    
    public init(model: View.Model, type: View.Type) {
        self.model = model
        self.type = type
    }
    
}
