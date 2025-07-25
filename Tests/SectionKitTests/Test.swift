//
//  Test.swift
//  SectionKit
//
//  Created by linhey on 7/25/25.
//

import Testing
import SectionKit
import Combine

struct Test {
    
    @available(iOS 16.0, *)
    @Test func SKPublish_Fatal_access_conflict_detected() async throws {
        
        class Value {
            let value: Int
            init(value: Int) {
                self.value = value
            }
        }
        
        var cancellables = Set<AnyCancellable>()
        @SKPublished var test: Value = .init(value: 0)
        $test.bind { newValue in
            print("test changed to \(test.value)")
            test = Value(value: 1)
        }.store(in: &cancellables)
        Task {
            test = Value(value: 1)
        }
        Task {
            test = Value(value: 2)
        }
        try await Task.sleep(for: .seconds(1))
    }

}
