# SectionKit

> iOS 动态表单框架

# 前提条件:

 - Swift 5.7 (Xcode 14+)
 - iOS 13.0+

# SKCSingleTypeSection & SKCRegistrationSection

## 创建通用型单元视图

> 通用型单元视图需要遵守 2 个 Protocol <br/> 1. SKConfigurableView: <br/> - 用于绑定视图与输入数据类型 <br/> - 用于确定视图尺寸 <br/> 2. SKLoadViewProtocol or SKLoadNibProtocol: 用于指定当前视图是代码加载还是从 Xib 加载

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

# SKCSingleTypeSection

> 单一数据类型 Section

- 创建 Section

    ``` swift
    let model = FLSpacerCell.Model(size: .zero)
    /// 以下 API 完全等价
    let section1 = FLSpacerCell.singleTypeWrapper([model])
    let section2 = FLSpacerCell.singleTypeWrapper(model)
    let section3 = SKCSingleTypeSection<FLSpacerCell>([model])
    let section4 = SKCSingleTypeSection<FLSpacerCell>(model)
    ```

- 与 UICollectionView 关联

    ``` swift
    /// 创建 Section
    let model = FLSpacerCell.Model(size: .zero)
    let section1 = FLSpacerCell.singleTypeWrapper([model])
    let section2 = FLCustomCell.singleTypeWrapper(model)

    /// manager 与 UICollectionView 关联
    let sectionView = UICollectionView(frame: .zero,collectionViewLayout: UICollectionViewFlowLayout())
    let manager = SKCManager(sectionView: sectionView)

    /// 加载 section1, section2
    manager.reload([section1, section2])
    ```

- 样式配置

    ``` swift
    let section = FLSpacerCell
        .singleTypeWrapper([model])

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
    let section = FLSpacerCell.singleTypeWrapper([model])
    /// 重置数据为 models
    section.config(models: [Model])
    /// 拼接数据至当前数据尾部
    section.append([Model])
    section.insert(at: 0, [Model])
    section.swapAt(0, 1)
    section.remove(0)
    section.remove(supplementary: .header)
    ```

- 事件订阅

    ``` swift
    let section = FLSpacerCell.singleTypeWrapper([model])

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