
SKSelection

> 可选元素集合管理

# SKSelectionSequence

> 有序序列管理实例

``` swift

let elements = [1,1,2,2,3,3].map { SKSelectionWrapp($0) }
let sequence = SKSelectionSequen(selectableElements: elements)

/// 选中全部数值为 1 的元素
sequence.selectAll(1)
/// 选中最后一个数值为 1 的元素
sequence.selectFirst(1)
/// 选中第一个全部数值为 1 的元素
sequence.selectLast(1)

let element = SKSelectionWrapper(1)
/// 选中全部与 element 相等的元素
sequence.selectAll(element)
/// 选中最后一个与 element 相等的元素
sequence.selectFirst(element)
/// 选中第一个与 element 相等的元素
sequence.selectLast(element)

// 全选
sequence.selectAll()
// 选中序列为 0 的元素
sequence.select(at: 0, isUnique: true, needInverttrue)
sequence.select(at: 0)
sequence.deselect(at: 0)

```

# SKSelectionIdentifiableSequence
> 无序序列管理实例

``` swift
let elements = [1,1,2,2,3,3].map { SKSelectionWrapp($0) }
let sequence = SKSelectionIdentifiableSequence(listelements, id: \.wrappedValue)
sequence.select(id: 1)
sequence.deselect(id: 1)
sequence.update(.init(4), by: \.wrappedValue)
```


# 与 Section 结合使用

``` swift
import UIKit
import SectionUI
import Combine

class CustomCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    
    typealias Model = SKSelectionWrapper<Int>
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return CGSize(width: size.width, height: size.height)
    }
    
    private var cancellable: AnyCancellable?
    
    func config(_ model: Model) {
        cancellable = model.selectedPublisher.sink(receiveValue: { [weak self] flag in
            guard let self = self else { return }
            self.contentView.backgroundColor = flag ? .red : .blue
        })
    }
    
}


class CustomSection: SKCSingleTypeSection<CustomCell>, SKSelectionSequenceProtocol {

    var selectableElements: [CustomCell.Model] { models }
    
    override func item(selected row: Int) {
        self.select(at: row, isUnique: true, needInvert: false)
    }
    
    func element(selected index: Int, element: SKSelectionWrapper<Int>) {
        sendAction(.selected, view: nil, row: index)
    }
    
}

let section = CustomSection()
section.pulishers.cellActionPulisher.sink { result in
    result.model.isSelected
}

```