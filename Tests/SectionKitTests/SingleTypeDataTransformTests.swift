//
//  File.swift
//  
//
//  Created by linhey on 2022/5/9.
//

import Foundation
import XCTest
import Combine
import SectionKit

final class SingleTypeDataTransformTests: XCTestCase {
   
    struct ValidModel: Equatable {
        let isValid: Bool
    }
    
    func testInitAndConfig() {
        let models = (0...100).map({ _ in ValidModel(isValid: .random()) })
        let section = SectionGenericCell<ValidModel>.singleTypeWrapper(models, transforms: [.init(task: { $0.filter(\.isValid) })])
        assert(section.models == models.filter(\.isValid))
        let models2 = (0...100).map({ _ in ValidModel(isValid: .random()) })
        section.config(models: models2)
        assert(section.models == models2.filter(\.isValid))
    }
    
}

