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

import Combine

public class SKSelectionState: Equatable {
    
    public var changedPublisher: AnyPublisher<SKSelectionState, Never> {
        Publishers
            .CombineLatest3(selectedPublisher, canSelectPublisher, isEnabledPublisher)
            .compactMap({ [weak self] _ in
                guard let self = self else { return nil }
                return self
            })
            .eraseToAnyPublisher()
    }
    
    public lazy var isEnabledPublisher: AnyPublisher<Bool, Never> = deferred(value: isEnabled, bind: \.isEnabledSubject)
    public lazy var canSelectPublisher: AnyPublisher<Bool, Never> = deferred(value: canSelect, bind: \.canSelectSubject)
    public lazy var selectedPublisher: AnyPublisher<Bool, Never>  = deferred(value: isSelected, bind: \.selectedSubject)
    
    private var selectedSubject:  CurrentValueSubject<Bool, Never>?
    private var canSelectSubject: CurrentValueSubject<Bool, Never>?
    private var isEnabledSubject: CurrentValueSubject<Bool, Never>?
    
    public static func == (lhs: SKSelectionState, rhs: SKSelectionState) -> Bool {
        return lhs.isSelected == rhs.isSelected
        && lhs.canSelect == rhs.canSelect
        && lhs.isEnabled == rhs.isEnabled
    }
    
    public var isSelected: Bool {
        didSet {
            selectedSubject?.send(isSelected)
        }
    }
    public var canSelect: Bool {
        didSet {
            canSelectSubject?.send(canSelect)
        }
    }
    /// 是否允许选中或取消选中操作
    public var isEnabled: Bool {
        didSet {
            isEnabledSubject?.send(isEnabled)
        }
    }
    
    public init(isSelected: Bool = false,
                canSelect: Bool = true,
                isEnabled: Bool = true) {
        self.isSelected = isSelected
        self.canSelect = canSelect
        self.isEnabled = isEnabled
    }
    
    func deferred(value: Bool, bind: WritableKeyPath<SKSelectionState, CurrentValueSubject<Bool, Never>?>) -> AnyPublisher<Bool, Never> {
        return Deferred { [weak self] in
            let subject = CurrentValueSubject<Bool, Never>(value)
            self?[keyPath: bind] = subject
            return subject.removeDuplicates() 
        }.eraseToAnyPublisher()
    }
    
}
