//
//  wrapperToSingleTypeSectionBuilderTest.swift
//  
//
//  Created by linhey on 2022/8/31.
//

import XCTest
import SectionUI

final class wrapperToSingleTypeSectionBuilderTest: XCTestCase {
    
    func builder(@SectionArrayResultBuilder<Int> builder: () -> [Int]) -> [Int] {
        builder()
    }
    
    func testExample() throws {
        let models = builder {
            { 1 }
            [1]
            2
        }
        
        assert(models == [1])
    }

}
