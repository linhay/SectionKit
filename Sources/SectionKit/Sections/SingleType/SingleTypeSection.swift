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

open class SingleTypeSection<Cell: UICollectionViewCell & ConfigurableView & SectionLoadViewProtocol>: SingleTypeCollectionDriveSection<Cell>, SectionCollectionFlowLayoutProtocol, SectionCollectionFlowLayoutSafeSizeProtocol, SectionDataSourcePrefetchingProtocol {
    
    public lazy var safeSize = defaultSafeSize
    
    open var minimumLineSpacing: CGFloat = 0
    open var minimumInteritemSpacing: CGFloat = 0
    open var sectionInset: UIEdgeInsets = .zero
    
    open var hiddenHeaderWhenNoItem: Bool = true
    open var hiddenFooterWhenNoItem: Bool = true
    open var isPrefetchingEnabled: Bool = true
    
    public private(set) lazy var headerViewProvider = SectionDelegate<SingleTypeSection<Cell>, UICollectionReusableView>()
    public private(set) lazy var footerViewProvider = SectionDelegate<SingleTypeSection<Cell>, UICollectionReusableView>()
    public private(set) lazy var headerSizeProvider = SectionDelegate<UICollectionView, CGSize>()
    public private(set) lazy var footerSizeProvider = SectionDelegate<UICollectionView, CGSize>()

    open var headerView: UICollectionReusableView? { headerViewProvider.call(self) }
    
    open var headerSize: CGSize { headerSizeProvider.call(sectionView) ?? .zero }
    
    open var footerView: UICollectionReusableView? { footerViewProvider.call(self) }
    
    open var footerSize: CGSize { footerSizeProvider.call(sectionView) ?? .zero }
    
    open func itemSize(at row: Int) -> CGSize {
        return Cell.preferredSize(limit: safeSize.size(self), model: models[row])
    }

}

#endif
