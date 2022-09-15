# SectionKit

A description of this package.

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
    
    class SupplementaryView: UICollectionReusableView, SKConfigurableView,     SKLoadViewProtocol {
        
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