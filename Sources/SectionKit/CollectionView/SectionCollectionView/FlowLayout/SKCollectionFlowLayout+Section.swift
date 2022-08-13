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
