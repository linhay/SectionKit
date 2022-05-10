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

#if canImport(UIKit)
import Combine
import UIKit

@dynamicMemberLookup
public final class SectionSelectableWrapper<Section: SingleTypeSectionEventProtocol & SectionProtocol>: SelectableCollectionProtocol, SectionWrapperProtocol where Section.Cell.Model: SelectableProtocol {
    public typealias Model = Section.Cell.Model
    public typealias Cell = Section.Cell
    
    public var selectables: [Section.Cell.Model] { wrappedSection.models }
    
    /// 是否保证选中在当前序列中是否唯一 | default: true
    private let isUnique: Bool
    /// 是否需要支持反选操作 | default: false
    private let needInvert: Bool
    
    public let wrappedSection: Section
    private var otherWrapper: Any?
    private var cancellables = Set<AnyCancellable>()
    
    public convenience init<Wrapper: SectionWrapperProtocol>(_ wrapper: Wrapper,
                                                             isUnique: Bool = true,
                                                             needInvert: Bool = false) where Wrapper.Section == Section
    {
        self.init(wrapper.wrappedSection, isUnique: isUnique, needInvert: needInvert)
        self.otherWrapper = wrapper
    }
    
    public init(_ section: Section, isUnique: Bool = true, needInvert: Bool = false) {
        self.wrappedSection = section
        self.isUnique = isUnique
        self.needInvert = needInvert
        
        section.publishers.cell.selected.map(\.row).sink { row in
            self.select(at: row, isUnique: isUnique, needInvert: needInvert)
        }.store(in: &cancellables)
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<Section, T>) -> T? {
        wrappedSection[keyPath: keyPath]
    }
}

public extension SectionProtocol where Self: SingleTypeSectionEventProtocol, Cell.Model: SelectableProtocol {
    func selectableWrapper(isUnique: Bool = true, needInvert: Bool = false) -> SectionSelectableWrapper<Self> {
        .init(self, isUnique: isUnique, needInvert: needInvert)
    }
}

public extension SectionWrapperProtocol where Section: SingleTypeSectionEventProtocol, Section.Cell.Model: SelectableProtocol {
    func selectableWrapper(isUnique: Bool = true, needInvert: Bool = false) -> SectionSelectableWrapper<Section> {
        .init(self, isUnique: isUnique, needInvert: needInvert)
    }
}
#endif
