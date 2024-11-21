//
//  SKCHostingSection.swift
//  SectionKit
//
//  Created by linhey on 11/21/24.
//

import Foundation
import SwiftUI
import SectionKit

public struct SKCHostingSection<Content: SKExistModelView & View>: SKCAnySectionProtocol {
   
    public let cell: Content.Type
    public let models: [Content.Model]
    public var style: (_ section: SKCSingleTypeSection<STCHostingCell<Content>>) -> Void
    
    public init(cell: Content.Type,
         models: [Content.Model],
         style: @escaping (_: SKCSingleTypeSection<STCHostingCell<Content>>) -> Void) {
        self.cell = cell
        self.models = models
        self.style = style
    }
    
    public var section: SKCSectionProtocol {
        Content
            .wrapperToCollectionCell()
            .wrapperToSingleTypeSection(models)
            .setSectionStyle(style)
    }
}
