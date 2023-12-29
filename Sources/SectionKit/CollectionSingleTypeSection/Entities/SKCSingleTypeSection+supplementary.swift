//
//  File.swift
//
//
//  Created by linhey on 2023/7/25.
//

import UIKit

public extension SKCSingleTypeSection {
    
    @discardableResult
    func set<View>(supplementary kind: SKSupplementaryKind,
                   type: View.Type,
                   model: @escaping () -> View.Model?,
                   config: ((View) -> Void)? = nil) -> Self where View: UICollectionReusableView & SKLoadViewProtocol & SKConfigurableView {
        set(supplementary: .init(kind: kind, type: type) { view in
            guard let model = model() else { return }
            view.config(model)
            config?(view)
        } size: { limitSize in
            guard let model = model() else { return .zero }
            return View.preferredSize(limit: limitSize, model: model)
        })
    }
    
    @discardableResult
    func set<View>(supplementary kind: SKSupplementaryKind,
                   type: View.Type,
                   model: View.Model,
                   config: ((View) -> Void)? = nil) -> Self where View: UICollectionReusableView & SKLoadViewProtocol & SKConfigurableView {
        set(supplementary: kind, type: type, model: {
            model
        }, config: config)
    }
    
    @discardableResult
    func set<View>(supplementary kind: SKSupplementaryKind,
                   type: View.Type,
                   model: SKBinding<View.Model?>,
                   config: ((View) -> Void)? = nil) -> Self where View: UICollectionReusableView & SKLoadViewProtocol & SKConfigurableView {
        set(supplementary: kind, type: type, model: {
            model.wrappedValue
        }, config: config)
    }
    
}

public extension SKCSingleTypeSection {
    
    @discardableResult
    func set<View>(supplementary kind: SKSupplementaryKind,
                   type: View.Type,
                   config: ((View) -> Void)? = nil) -> Self where View: UICollectionReusableView & SKLoadViewProtocol & SKConfigurableView, View.Model == Void {
        set(supplementary: kind, type: type, model: (), config: config)
    }
    
}


public extension SKCSingleTypeSection {
    
    @discardableResult
    func remove(supplementary kind: SKSupplementaryKind) -> Self {
        supplementaries[kind] = nil
        reload()
        return self
    }
    
    @discardableResult
    func set<View>(supplementary kind: SKSupplementaryKind,
                   type: View.Type,
                   config: ((View) -> Void)? = nil,
                   size: @escaping (_ limitSize: CGSize) -> CGSize) -> Self where View: UICollectionReusableView & SKLoadViewProtocol & SKConfigurableView {
        set(supplementary: .init(kind: kind, type: type, config: config, size: size))
    }
    
    @discardableResult
    func set<T>(supplementary: SKCSupplementary<T>) -> Self {
        taskIfLoaded { section in
            section.register(supplementary.type, for: supplementary.kind)
        }
        supplementaries[supplementary.kind] = supplementary
        reload()
        return self
    }
    
}
