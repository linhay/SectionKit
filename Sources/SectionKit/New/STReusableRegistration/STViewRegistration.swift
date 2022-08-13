//
//  STCollectionCellRegistration.swift
//  
//
//  Created by linhey on 2022/8/11.
//

import UIKit

public extension SKConfigurableView where Self: SKLoadViewProtocol {
    
    static func registration(_ model: Model) -> STViewRegistration<Self, Int> {
        return .init(model: model, type: Self.self)
    }
    
    static func registration(_ models: [Model]) -> [STViewRegistration<Self, Int>] {
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

public class STViewRegistration<View: SKLoadViewProtocol & SKConfigurableView, ID: Hashable>: STViewRegistrationProtocol, Identifiable {
    
    public var indexPath: IndexPath?
    public let model: View.Model
    public let type: View.Type
    public let idKeyPath: KeyPath<View.Model, ID>?
    public var id: ID?
    
    public convenience init(model: View.Model, type: View.Type) where View.Model: Hashable, ID == View.Model {
        self.init(model: model, type: type, id: \.self)
    }
    
    public init(model: View.Model, type: View.Type) where ID == Int {
        self.model = model
        self.type = type
        self.idKeyPath = nil
        self.id = nil
    }

    public init(model: View.Model, type: View.Type, id: KeyPath<View.Model, ID>?) {
        self.model = model
        self.type = type
        self.idKeyPath = id
        if let id = id {
            self.id = model[keyPath: id]
        }
    }
}
