// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation

@dynamicMemberLookup
public struct SelectableBox<SelectableValue>: SelectableProtocol {
    
    public var selectableModel: SelectableModel
    public var value: SelectableValue
    
    public init(_ value: SelectableValue, selectable: SelectableModel = SelectableModel()) {
        self.value = value
        self.selectableModel = selectable
    }
    
    public subscript<T>(dynamicMember keyPath: WritableKeyPath<SelectableValue, T>) -> T {
        get { value[keyPath: keyPath] }
        set { value[keyPath: keyPath] = newValue }
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<SelectableValue, T>) -> T {
        value[keyPath: keyPath]
    }
    
}

extension SelectableBox: Equatable where SelectableValue: Equatable {
    
    public static func == (lhs: SelectableBox<SelectableValue>, rhs: SelectableBox<SelectableValue>) -> Bool {
        return lhs.value == rhs.value && lhs.selectableModel == rhs.selectableModel
    }
    
}

extension SelectableBox: Identifiable where SelectableValue: Identifiable {
    
    public var id: SelectableValue.ID { value.id }
    
}
