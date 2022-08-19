//
//  File.swift
//
//
//  Created by linhey on 2022/5/5.
//

import Foundation

public extension SKCollectionFlowLayout.BindingKey where Value == Int {
    convenience init(_ section: SKSectionProtocol) {
        self.init(get: { section.isLoaded ? section.sectionIndex : nil })
    }
}


public extension SKCollectionFlowLayout.BindingKey where Value == Int {
    
    convenience init(_ section: SKCSectionActionProtocol) {
        self.init(get: { [weak section] in
            guard let section = section, let injection = section.sectionInjection else {
                return nil
            }
            return injection.index
        })
    }
    
}
