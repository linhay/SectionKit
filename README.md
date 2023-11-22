# SectionKit

> iOS 动态表单框架

![](./Documentation/Images/icon.svg)

## 特点
- [x] 支持 UICollectionView
- [ ] 支持 UITableView
- [x] 促进代码的模块化和重用
- [x] 简化复杂表单的管理

## 前提条件:

 - Swift 5.7 (Xcode 14+)
 - iOS 13.0+

## 安装

- Cocoapods

    ``` ruby
    pod 'SectionKit2', '2.0.0-beta.1'
    or
    pod 'SectionUI', '2.0.0-beta.1'
    ```

-  Swift Packages URL

    ``` swift
    https://github.com/linhay/SectionKit
    ```

## 其他文档

 - 数据选中 [SKSelection](./Documentation/SKSelection.md)
 - 辅助工具 [Shell](./Documentation/Shells.md)

## 快速开始

> 一个简单的例子，展示如何使用 SectionKit 创建一个表单。

-  UICollectionViewCell:

    ``` swift
    import UIKit
    import SectionKit
    
    class SpacerCell: UICollectionViewCell, SKConfigurableView, SKLoadViewProtocol {
        
        public struct Model {
            public let size: CGSize
            public let backgroundColor: UIColor?
        }
        
        public func config(_ model: Model) {
            self.backgroundColor = model.backgroundColor
        }
        
        public static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
            guard let model = model else {
                return .zero
            }
            return model.size
        }
        
    }
    ```

- UICollectionReusableView:

    ``` swift
    import UIKit
    import SectionKit
    
    class SupplementaryView: UICollectionReusableView, SKConfigurableView, SKLoadViewProtocol {
        
        static func preferredSize(limit size: CGSize, model: Void?) -> CGSize {
            return CGSize(width: size.width, height: 44)
        }
        
        func config(_ model: Void) {
            
        }
        
    }
    ```

## SKCSingleTypeSection

> 单一数据类型 Section

- 创建 Section

    ``` swift
    let model = FLSpacerCell.Model(size: .zero)
    /// 以下 API 完全等价
    let section1 = FLSpacerCell.wrapperToSingleTypeSection([model])
    let section2 = FLSpacerCell.wrapperToSingleTypeSection(model)
    let section3 = SKCSingleTypeSection<FLSpacerCell>([model])
    let section4 = SKCSingleTypeSection<FLSpacerCell>(model)
    ```

- 与 UICollectionView 关联

    ``` swift
    /// 创建 Section
    let model = FLSpacerCell.Model(size: .zero)
    let section1 = FLSpacerCell.wrapperToSingleTypeSection([model])
    let section2 = FLCustomCell.wrapperToSingleTypeSection(model)

    /// manager 与 UICollectionView 关联
    let sectionView = UICollectionView(frame: .zero,collectionViewLayout: UICollectionViewFlowLayout())
    let manager = SKCManager(sectionView: sectionView)

    /// 加载 section1, section2
    manager.reload([section1, section2])
    ```

- 样式配置

    ``` swift
    let section = FLSpacerCell
        .wrapperToSingleTypeSection([model])

        /// 配置当前 section 样式
        .setSectionStyle({ section in
            section.minimumLineSpacing = 10
            section.minimumInteritemSpacing = 10
            section.sectionInset = .init(top: 20, left: 20, bottom: 20,right: 20)
        })

        /// 加载指定 row 时可以通过 setCellStyle 额外配置 cell 样式
        .setCellStyle { context in
            context.model
            context.row
            context.view
            context.section
        }

        /// 配置 headerView & footerView
        .set(supplementary: .header(type: SupplementaryView.self,model: ()))
        .set(supplementary: .header(type: SupplementaryView.self,config: { view in
            view.backgroundColor = .red
        }, size: { limitSize in
            return .init(width: 375, height: 44)
        }))

        /// 配置 headerView & footerView, 与上述函数等价
        .set(supplementary: .init(kind: .header, type:SupplementaryView.self, model: ()))
        .set(supplementary: .init(kind: .header, type:SupplementaryView.self, config: { view in
            view.backgroundColor = .red
        }, size: { limitSize in
            return .init(width: 375, height: 44)
        }))

        /// 响应 cell 选中事件
        .onCellAction(.selected) { context in
            context.model
            context.row
            context.view()
            context.section
        }
        .onCellAction(.config) { _ in }
        .onCellAction(.willDisplay) { _ in }
        .onCellAction(.didEndDisplay) { _ in }
        
        /// 响应 SupplementaryView 消失事件
        .onSupplementaryAction(.didEndDisplay) { context in
            context.row
            context.type
            context.kind
            context.section
        }
        .onSupplementaryAction(.willDisplay, block: { _ in })
    ```

- 数据操作

    > 修改数据后会刷新响应视图, 无需手动刷新

    ``` swift
    let section = FLSpacerCell.wrapperToSingleTypeSection([model])
    /// 重置数据为 models
    _ = section.config(models: [Model])
    section.apply(models: [Model])
    /// 拼接数据至当前数据尾部
    section.append([Model])
    section.insert(at: 0, [Model])
    section.swapAt(0, 1)
    section.remove(0)
    section.remove(supplementary: .header)
    ```

- 事件订阅

    ``` swift
    let section = FLSpacerCell.wrapperToSingleTypeSection([model])
    
    section.pulishers.cellActionPulisher.sink { context in
        switch context.type {
        case .selected:
            break
        case .willDisplay:
            break
        case .didEndDisplay:
            break
        case .config:
            break
        }
    }
    
    section.pulishers.supplementaryActionPulisher.sink { context in
        switch context.type {
        case .willDisplay:
            break
        case .didEndDisplay:
            break
        }
    }
    
    /// 以下事件依托于 UICollectionViewDataSourcePrefetching 能力
    
    /// 预测需要显示的 row 已经超过当前的 cell 数量
    section.prefetch.loadMorePublisher.sink { _ in
            
    }
        
    /// 预测需要显示的 rows
    section.prefetch.prefetchPublisher.sink { rows in
            
    }
        
    section.prefetch.cancelPrefetchingPublisher.sink { rows in
            
    }
    ```

## SKCRegistrationSection

> 复数数据类型 Section, 生成后所有的操作都会通过 diff 来更新视图

- 创建 Section

    ``` swift
    /// 以下方式完全等价

    /// 由 @resultBuilder 提供语法支持
    let section1 = SKCRegistrationSection {
        SupplementaryView.registration((), for: .header)
        SupplementaryView.registration((), for: .footer)
        FLSpacerCell.registration(model)
        FLCustomCell.registration(model)
        FLSpacerCell.registration(model)
    }
    
    let section2 = SKCRegistrationSection([.header: SupplementaryView.registration((), for: .header),
                                           .footer: SupplementaryView.registration((), for: .footer)],
                                          [FLSpacerCell.registration(model),
                                           FLCustomCell.registration(model),
                                           FLSpacerCell.registration(model)])
    ```

- 与 UICollectionView 关联

    ``` swift
    /// manager 与 UICollectionView 关联
    let sectionView = UICollectionView(frame: .zerocollectionViewLayout: UICollectionViewFlowLayout())
    let manager = SKCRegistrationManager(sectionView:sectionView)
    /// 加载 section1, section2
    manager.reload([section1, section2])
    ```

- 样式配置

    ``` swift
    let section = SKCRegistrationSection {
        SupplementaryView
            .registration((), for: .header)
            /// 配置 supplementary 样式
            .viewStyle({ view, model in })
            .onWillDisplay { model in }
            .onEndDisplaying { model in }
            
        FLSpacerCell
            .registration(model)
            /// 配置 cell 样式
            .viewStyle({ view, model in })
            /// 响应 cell 选中事件
            .onSelected { model in }
            .onHighlight { model in }
            .onWillDisplay { model in }
            .onEndDisplaying { model in }
            // ...
    }
    /// 配置 section 样式
    .setSectionStyle { section in
        section.minimumInteritemSpacing = 10
        section.minimumLineSpacing = 10
        section.sectionInset = .init(top: 10, left: 10, bottom: 10,right: 10)
    }
    ```

- 数据操作

    ``` swift
    let section = SKCRegistrationSection {
        // ...
    }

    /// 重置所有视图
    section.apply(on: self) { (self, section) in
        SupplementaryView.registration((), for: .header)
        FLSpacerCell.registration(model)
        // ...
    }
    
    section.apply {
        SupplementaryView.registration((), for: .header)
        FLSpacerCell.registration(model)
        // ...
    }
    
    /// 重置所有 Cell 视图
    section.apply(cell: FLSpacerCell.registration(model))
    section.apply(cell: [FLSpacerCell.registration(model)])

    /// 重置所有 Supplementary 视图
    section.apply(supplementary: SupplementaryView.registration((), for: .header))
    section.apply(supplementary: [SupplementaryView.registration((), for: .header),
                                  SupplementaryView.registration((), for: .footer)])
    section.apply(supplementary: [.header: SupplementaryView.registration((), for: .header)])

    // 局部操作
    let cell = FLSpacerCell.registration(model)
    section.delete(cell: cell)
    section.reload(cell: cell)

    // 局部操作
    let view = SupplementaryView.registration((), for: .header)
    section.insert(supplementary: view)
    section.delete(supplementary: view)
    ```

- 事件订阅

    ``` swift
    /// 以下事件依托于 UICollectionViewDataSourcePrefetching 能力
    
    /// 预测需要显示的 row 已经超过当前的 cell 数量
    section.prefetch.loadMorePublisher.sink { _ in
            
    }
        
    /// 预测需要显示的 rows
    section.prefetch.prefetchPublisher.sink { rows in
            
    }
        
    section.prefetch.cancelPrefetchingPublisher.sink { rows in
            
    }
    ```

## 自定义 Section 

> 最基础的 protocol, SKCRegistrationSection, SKCSingleTypeSection 由此封装

- 创建 Section

    ``` swift
    import UIKit
    import SectionKit
    
    class CustomSection: SKCSectionProtocol {
        
        var sectionInjection: SKCSectionInjection?
        
        var minimumLineSpacing: CGFloat = 10
        var minimumInteritemSpacing: CGFloat = 10
        var sectionInset: UIEdgeInsets = .init(top: 20, left: 20, bottom: 20, right: 20)
        
        var itemCount: Int { 0 }
        
        func config(sectionView: UICollectionView) {
            register(StringCell.self)
        }
        
        func itemSize(at row: Int) -> CGSize {
            return .init(width: 44, height: 44)
        }
        
        func item(at row: Int) -> UICollectionViewCell {
            let cell = dequeue(at: row) as StringCell
            return cell
        }
        
        func item(selected row: Int) {}
        func item(willDisplay view: UICollectionViewCell, row: Int) {}
        func item(didEndDisplaying view: UICollectionViewCell, row: Int) {}
        func item(didBeginMultipleSelectionInteraction row: Int) {}
        /// ...
    }
    ```

- 与 UICollectionView 关联

    ``` swift
    /// 创建 Section
    let section1 = CustomSection()
    let section2 = CustomSection()

    /// manager 与 UICollectionView 关联
    let sectionView = UICollectionView(frame: .zero,collectionViewLayout: UICollectionViewFlowLayout())
    let manager = SKCManager(sectionView: sectionView)

    /// 加载 section1, section2
    manager.reload([section1, section2])
    ```

- 数据操作
  
    - 无默认实现

- 事件订阅

    - 无默认实现
