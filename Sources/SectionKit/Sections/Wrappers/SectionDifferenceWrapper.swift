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
import UIKit

@dynamicMemberLookup
public final class SectionDifferenceWrapper<Section: SingleTypeSectionDataProtocol & SKSectionProtocol>: SKWrapperProtocol {
    public typealias Model = Section.Cell.Model
    public typealias Cell = Section.Cell
    
    public let wrappedSection: Section
    private var otherWrapper: Any?
    
    public init(_ section: Section) {
        self.wrappedSection = section
    }
    
    public convenience init<Wrapper: SKWrapperProtocol>(_ wrapper: Wrapper) where Wrapper.Section == Section {
        self.init(wrapper.wrappedSection)
        self.otherWrapper = wrapper
    }
    
    public func config(models: [Model]) where Model: Hashable {
        config(models: models, areEquivalent: { $0.hashValue == $1.hashValue })
    }
    
    public func config<ID: Hashable>(models: [Model], id: KeyPath<Model, ID>) {
        config(models: models, areEquivalent: { $0[keyPath: id] == $1[keyPath: id] })
    }
    
    public func config(models: [Model], areEquivalent: (Model, Model) -> Bool) {
        let new = wrappedSection.dataSource.modelsFilter(models, transforms: wrappedSection.dataSource.dataTransforms)
        guard new.isEmpty == false, wrappedSection.isLoaded else {
            wrappedSection.config(models: new)
            return
        }
        
        wrappedSection.pick({
            for change in new.difference(from: wrappedSection.models, by: areEquivalent) {
                switch change {
                case let .remove(offset, _, _):
                    wrappedSection.remove(at: offset)
                case let .insert(offset, element, _):
                    wrappedSection.insert(element, at: offset)
                }
            }
        }, completion: nil)
    }
    
    public subscript<T>(dynamicMember keyPath: KeyPath<Section, T>) -> T? {
        wrappedSection[keyPath: keyPath]
    }
}

public extension SKSectionProtocol where Self: SingleTypeSectionDataProtocol {
    var differenceWrapper: SectionDifferenceWrapper<Self> { .init(self) }
}

public extension SKWrapperProtocol where Section: SingleTypeSectionDataProtocol {
    var differenceWrapper: SectionDifferenceWrapper<Section> {
        .init(self)
    }
}
#endif
