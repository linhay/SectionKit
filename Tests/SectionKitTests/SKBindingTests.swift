//
//  File.swift
//  
//
//  Created by linhey on 2023/3/9.
//

import SectionUI
import XCTest

class SKBindingTests: XCTestCase {
    
    class TestObject {
        var value: String = "initial"
    }
    
    func testConstantBinding() {
        let binding = SKBinding.constant("test")
        XCTAssertEqual(binding.wrappedValue, "test")
    }
    
    func testExistingBinding() {
        let sourceBinding = SKBinding(get: { "source" }, set: { _ in })
        let binding = SKBinding(sourceBinding)
        XCTAssertEqual(binding.wrappedValue, "source")
    }
    
    func testKeyPathBinding() {
        let testObject = TestObject()
        let binding = SKBinding(on: testObject, keyPath: \.value)
        XCTAssertEqual(binding.wrappedValue, "initial")
        
        binding.wrappedValue = "modified"
        XCTAssertEqual(testObject.value, "modified")
    }
    
}
