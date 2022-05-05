//
//  File.swift
//  
//
//  Created by linhey on 2022/5/5.
//

import Foundation

public extension SectionCollectionFlowLayout.BindingKey where Value == Int {
    
    convenience init(_ section: SectionProtocol) {
        self.init(get: { section.isLoaded ? section.sectionIndex : nil })
    }
    
}
