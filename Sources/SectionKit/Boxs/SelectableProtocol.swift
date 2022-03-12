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

public class SelectableModel: Equatable {
    
    let selectedSubject: Publishers.RemoveDuplicates<CurrentValueSubject<Bool, Never>>
    let canSelectSubject: Publishers.RemoveDuplicates<CurrentValueSubject<Bool, Never>>
    let changedSubject = PassthroughSubject<(isSelected: Bool, canSelect: Bool), Never>()
    
    public static func == (lhs: SelectableModel, rhs: SelectableModel) -> Bool {
       return lhs.isSelected == rhs.isSelected && lhs.canSelect == rhs.canSelect
    }
    
    public var isSelected: Bool {
        set { selectedSubject.upstream.send(newValue) }
        get { selectedSubject.upstream.value }
    }
    
    public var canSelect: Bool {
        set { canSelectSubject.upstream.send(newValue) }
        get { canSelectSubject.upstream.value }
    }

    private var cancellables = Set<AnyCancellable>()
    
    public init(isSelected: Bool = false, canSelect: Bool = true) {
        self.selectedSubject  = CurrentValueSubject<Bool, Never>(isSelected).removeDuplicates()
        self.canSelectSubject = CurrentValueSubject<Bool, Never>(canSelect).removeDuplicates()
        
        self.selectedSubject.sink { value in
            self.changedSubject.send((isSelected, canSelect))
        }.store(in: &cancellables)
        
        self.canSelectSubject.sink { value in
            self.changedSubject.send((isSelected, canSelect))
        }.store(in: &cancellables)
    }

}

public protocol SelectableProtocol {

    var selectableModel: SelectableModel { get }

}

public extension SelectableProtocol {

    var isSelected: Bool { selectableModel.isSelected }
    var canSelect: Bool { selectableModel.canSelect }
    
    var selectedObservable: AnyPublisher<Bool, Never> { selectableModel.selectedSubject.eraseToAnyPublisher() }
    var canSelectObservable: AnyPublisher<Bool, Never> { selectableModel.canSelectSubject.eraseToAnyPublisher() }
    var changedObservable: AnyPublisher<(isSelected: Bool, canSelect: Bool), Never> { selectableModel.changedSubject.eraseToAnyPublisher() }

}

public protocol SelectableCollectionProtocol {
    
    associatedtype Element: SelectableProtocol

    /// 可选元素序列
    var selectables: [Element] { get }

    /// 已选中某个元素
    /// - Parameters:
    ///   - index: 选中元素索引
    ///   - element: 选中元素
    func didSelectElement(at index: Int, element: Element)
}

public extension SelectableCollectionProtocol {

    func didSelectElement(at index: Int, element: Element) { }

}

public extension SelectableCollectionProtocol {

    /// 序列中第一个选中的元素
    func firstSelectedElement() -> Element? {
        return selectables.first(where: { $0.isSelected })
    }

    /// 序列中第一个选中的元素的索引
    func firstSelectedIndex() -> Int? {
        return selectables.firstIndex(where: { $0.isSelected })
    }

    /// 选中元素
    /// - Parameters:
    ///   - index: 选择序号
    ///   - isUnique: 是否保证选中在当前序列中是否唯一 | default: true
    ///   - needInvert: 是否需要支持反选操作 | default: false
    func select(at index: Int, isUnique: Bool = true, needInvert: Bool = false) {
        guard index >= 0, index < selectables.count else {
            return
        }
        
        let element = selectables[index]
        
        guard element.canSelect else {
            return
        }

        guard isUnique else {
            element.selectableModel.isSelected = needInvert ? !element.isSelected : true
            didSelectElement(at: index, element: element)
            return
        }

        for (offset, item) in selectables.enumerated() {
            if offset == index {
                item.selectableModel.isSelected = needInvert ? !element.isSelected : true
            } else {
                item.selectableModel.isSelected = false
            }
        }
        didSelectElement(at: index, element: element)
    }

}

public extension SelectableCollectionProtocol where Element: Equatable {

    /// 选中指定元素
    /// - Parameters:
    ///   - element: 指定元素
    ///   - needInvert: 是否需要支持反选操作 | default: false
    func select(_ element: Element, needInvert: Bool = false) {
        guard selectables.contains(element) else {
            return
        }

        for (offset, item) in selectables.enumerated() {
            item.selectableModel.isSelected = needInvert ? !item.isSelected : item == element
            if item == element {
                didSelectElement(at: offset, element: element)
            }
        }
    }

}
