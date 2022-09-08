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
    
    let selectedSubject: CurrentValueSubject<Bool, Never>
    let canSelectSubject: CurrentValueSubject<Bool, Never>
    let changedSubject = PassthroughSubject<SKSelectionState, Never>()

    public static func == (lhs: SKSelectionState, rhs: SKSelectionState) -> Bool {
        return lhs.isSelected == rhs.isSelected && lhs.canSelect == rhs.canSelect
    }
    
    public var isSelected: Bool {
        set { selectedSubject.send(newValue) }
        get { selectedSubject.value }
    }
    
    public var canSelect: Bool {
        set { canSelectSubject.send(newValue) }
        get { canSelectSubject.value }
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    public init(isSelected: Bool = false, canSelect: Bool = true) {
        selectedSubject = CurrentValueSubject<Bool, Never>(isSelected)
        canSelectSubject = CurrentValueSubject<Bool, Never>(canSelect)
        
        selectedSubject.sink { [weak self] value in
            guard let self = self else { return }
            self.changedSubject.send(self)
        }.store(in: &cancellables)
        
        canSelectSubject.sink { [weak self] value in
            guard let self = self else { return }
            self.changedSubject.send(self)
        }.store(in: &cancellables)
    }
}
