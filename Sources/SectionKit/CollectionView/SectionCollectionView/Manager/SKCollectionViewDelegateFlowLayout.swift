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

// MARK: - UICollectionViewDelegateFlowLayout

class SKCollectionViewDelegateFlowLayout: SKOldCollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    private func flowLayoutSection(from indexPath: IndexPath) -> SKCollectionFlowLayoutProtocol? {
        guard let layout = section(from: indexPath) as? SKCollectionFlowLayoutProtocol else {
            assertionFailure("未实现 SectionCollectionFlowLayoutProtocol")
            return nil
        }
        return layout
    }
    
    private func flowLayoutSection(from index: Int) -> SKCollectionFlowLayoutProtocol? {
        guard let layout = sectionEvent.call(index) as? SKCollectionFlowLayoutProtocol else {
            assertionFailure("未实现 SectionCollectionFlowLayoutProtocol")
            return nil
        }
        return layout
    }
    
    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let section = flowLayoutSection(from: indexPath) else {
            return .zero
        }
        let size = section.itemSize(at: indexPath.item)
        if indexPath.section == 0, indexPath.row == 0, size == .zero {
            return .init(width: 0.01, height: 0.01)
        } else {
            return size
        }
    }
    
    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        guard let section = flowLayoutSection(from: section) else {
            return .zero
        }
        if section.hiddenHeaderWhenNoItem, section.itemCount == 0 {
            return .zero
        } else {
            return section.headerSize
        }
    }
    
    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let section = flowLayoutSection(from: section) else {
            return .zero
        }
        if section.hiddenFooterWhenNoItem, section.itemCount == 0 {
            return .zero
        } else {
            return section.footerSize
        }
    }
    
    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        guard let section = flowLayoutSection(from: section) else {
            return .zero
        }
        return section.itemCount == 0 ? .zero : section.minimumLineSpacing
    }
    
    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        guard let section = flowLayoutSection(from: section) else {
            return .zero
        }
        return section.itemCount == 0 ? .zero : section.minimumInteritemSpacing
    }
    
    public func collectionView(_: UICollectionView, layout _: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        guard let section = flowLayoutSection(from: section) else {
            return .zero
        }
        if section.hiddenFooterWhenNoItem, section.hiddenHeaderWhenNoItem, section.itemCount == 0 {
            return .zero
        } else {
            return section.sectionInset
        }
    }
}
#endif
