import UIKit

@available(*, deprecated, message: "[beta] 测试版，功能未完善")
public class SKWaterfallLayout: UICollectionViewLayout {
    
    /// 高度计算模式
    public enum HeightCalculationMode {
        /// 保持宽高比：根据列宽按比例缩放高度
        case aspectRatio
        /// 固定高度：不改变原始高度
        case fixed
    }
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0
    
    /// 列宽比例数组，例如 [0.5, 0.5] 表示两列等宽，[0.3, 0.7] 表示第一列占30%，第二列占70%
    public var columnWidthRatios: [CGFloat] = [1] {
        didSet {
            // 确保比例总和为 1.0
            let sum = columnWidthRatios.reduce(0, +)
            if abs(sum - 1.0) > 0 {
                assertionFailure("⚠️ Warning: columnWidthRatios sum is \(sum), should be 1.0")
            }
        }
    }
    
    /// 高度计算模式，默认为保持宽高比
    public var heightCalculationMode: HeightCalculationMode = .fixed
    
    private var numberOfColumns: Int {
        return columnWidthRatios.count
    }
    
    private var contentWidth: CGFloat {
        guard let collectionView = collectionView else { return 0 }
        let insets = collectionView.adjustedContentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    public override var collectionViewContentSize: CGSize {
        CGSize(width: contentWidth, height: contentHeight)
    }
    
    public override func prepare() {
        guard let collectionView,
              cache.isEmpty,
              collectionView.numberOfSections > 0,
              let layout = collectionView.delegate as? UICollectionViewDelegateFlowLayout
        else { return }
        
        cache.removeAll()
        contentHeight = 0
        // 遍历所有 sections
        for section in 0..<collectionView.numberOfSections {
            prepareSectionLayout(for: section, in: collectionView, with: layout)
        }
    }
    
    private func prepareSectionLayout(for section: Int, in collectionView: UICollectionView, with layout: UICollectionViewDelegateFlowLayout) {
        let sectionInset = layout.collectionView?(collectionView, layout: self, insetForSectionAt: section) ?? .zero
        let minimumLineSpacing = layout.collectionView?(collectionView, layout: self, minimumLineSpacingForSectionAt: section) ?? 0
        let minimumInteritemSpacing = layout.collectionView?(collectionView, layout: self, minimumInteritemSpacingForSectionAt: section) ?? 0
        let availableWidth = contentWidth - sectionInset.left - sectionInset.right
        let numberOfItems = collectionView.numberOfItems(inSection: section)
        
        // 添加 Header
        let headerSize = layout.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: section) ?? .zero
        if headerSize.height > 0 {
            let headerAttributes = UICollectionViewLayoutAttributes(
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                with: IndexPath(item: 0, section: section)
            )
            headerAttributes.frame = CGRect(x: sectionInset.left, y: contentHeight, width: availableWidth, height: headerSize.height)
            cache.append(headerAttributes)
            contentHeight += headerSize.height
        }
        
        // 如果没有 items，跳过布局
        guard numberOfItems > 0 else { return }
        
        // 计算每列的宽度和起始X位置
        var columnWidths: [CGFloat] = []
        var columnXOffsets: [CGFloat] = []
        var currentX: CGFloat = sectionInset.left
        
        let totalSpacing = CGFloat(numberOfColumns - 1) * minimumInteritemSpacing
        let availableWidthForColumns = availableWidth - totalSpacing
        
        for ratio in columnWidthRatios {
            let columnWidth = availableWidthForColumns * ratio
            columnWidths.append(columnWidth)
            columnXOffsets.append(currentX)
            currentX += columnWidth + minimumInteritemSpacing
        }
        
        // 记录每一列的当前 Y 位置
        var columnHeights: [CGFloat] = Array(repeating: contentHeight + sectionInset.top, count: numberOfColumns)
        
        for item in 0..<numberOfItems {
            let indexPath = IndexPath(item: item, section: section)
            guard let itemSize = layout.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) else {
                continue
            }
            
            // 找到最短的列
            let shortestColumnIndex = columnHeights.enumerated().min(by: { $0.element < $1.element })?.offset ?? 0
            
            // 获取该列的宽度
            let columnWidth = columnWidths[shortestColumnIndex]
            
            // 根据高度计算模式计算 item 的高度
            let itemHeight: CGFloat
            switch heightCalculationMode {
            case .aspectRatio:
                // 保持宽高比：根据列宽按比例缩放高度
                itemHeight = (columnWidth / itemSize.width) * itemSize.height
            case .fixed:
                // 固定高度：使用原始高度
                itemHeight = itemSize.height
            }
            
            // 计算 frame
            let xOffset = columnXOffsets[shortestColumnIndex]
            let yOffset = columnHeights[shortestColumnIndex]
            
            let frame = CGRect(x: xOffset, y: yOffset, width: columnWidth, height: itemHeight)
            
            // 创建 layout attributes
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
            
            // 更新该列的高度
            columnHeights[shortestColumnIndex] += itemHeight + minimumLineSpacing
            
            // 更新总高度
            contentHeight = max(contentHeight, columnHeights[shortestColumnIndex])
        }
        
        // 添加 section 底部间距
        contentHeight = (columnHeights.max() ?? contentHeight) + sectionInset.bottom - minimumLineSpacing
        
        let footerSize = layout.collectionView?(collectionView, layout: self, referenceSizeForFooterInSection: section) ?? .zero
        if footerSize.height > 0 {
            let footerAttributes = UICollectionViewLayoutAttributes(
                forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                with: IndexPath(item: 0, section: section)
            )
            footerAttributes.frame = CGRect(x: sectionInset.left, y: contentHeight, width: availableWidth, height: footerSize.height)
            cache.append(footerAttributes)
            contentHeight += footerSize.height
        }
    }
    
   public override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        cache.filter { $0.frame.intersects(rect) }
    }
    
    public override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cache.first { $0.indexPath == indexPath }
    }
    
    public override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cache.first { $0.representedElementKind == elementKind && $0.indexPath == indexPath }
    }
    
    public override func invalidateLayout() {
        super.invalidateLayout()
        cache.removeAll()
        contentHeight = 0
    }
}


public extension SKWaterfallLayout {
    
    /// 链式设置列宽比例
    /// - Parameter value: 列数，等分比例
    /// - Returns: 返回自身，支持链式调用
    func columnWidth(equalParts value: Int) -> Self {
        return columnWidth(ratios: Array(repeating: 1.0 / CGFloat(value), count: value))
    }
    
    /// 链式设置列宽比例
    /// - Parameter value: 列宽比例数组
    /// - Returns: 返回自身，支持链式调用
    func columnWidth(ratios value: [CGFloat]) -> Self {
        self.columnWidthRatios = value
        return self
    }
    
    /// 链式设置高度计算模式
    /// - Parameter value: 高度计算模式
    /// - Returns: 返回自身，支持链式调用
    func heightCalculationMode(_ value: HeightCalculationMode) -> Self {
        self.heightCalculationMode = value
        return self
    }
    
}
