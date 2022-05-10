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

#if canImport(UIKit) && canImport(Combine)
import Combine
import UIKit

public struct SingleTypeSectionPublishers<Model, ReusableView> {
    public struct SelectedResult<Model> {
        public let row: Int
        public let model: Model
    }
    
    public struct SupplementaryResult {
        public let view: ReusableView
        public let elementKind: SectionSupplementaryKind
        public let row: Int
    }
    
    public struct Supplementary {
        public var willDisplay: AnyPublisher<SupplementaryResult, Never> { _willDisplay.eraseToAnyPublisher() }
        public var didEndDisplaying: AnyPublisher<SupplementaryResult, Never> { _didEndDisplaying.eraseToAnyPublisher() }
        
        var _willDisplay = PassthroughSubject<SupplementaryResult, Never>()
        var _didEndDisplaying = PassthroughSubject<SupplementaryResult, Never>()
    }
    
    public struct Cell {
        public var selected: AnyPublisher<SelectedResult<Model>, Never> { _selected.eraseToAnyPublisher() }
        public var willDisplay: AnyPublisher<SelectedResult<Model>, Never> { _willDisplay.eraseToAnyPublisher() }
        public var didEndDisplaying: AnyPublisher<SelectedResult<Model>, Never> { _didEndDisplaying.eraseToAnyPublisher() }
        
        var _selected = PassthroughSubject<SelectedResult<Model>, Never>()
        var _willDisplay = PassthroughSubject<SelectedResult<Model>, Never>()
        var _didEndDisplaying = PassthroughSubject<SelectedResult<Model>, Never>()
    }
    
    public struct Prefetch {
        public var begin: AnyPublisher<[Int], Never> { _begin.eraseToAnyPublisher() }
        public var cancel: AnyPublisher<[Int], Never> { _cancel.eraseToAnyPublisher() }
        
        var _begin = PassthroughSubject<[Int], Never>()
        var _cancel = PassthroughSubject<[Int], Never>()
    }
    
    public let cell = Cell()
    public let supplementary = Supplementary()
    public let prefetch = Prefetch()
}
#endif
