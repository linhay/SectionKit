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
import Foundation
import UIKit

public class SectionSafeSize {
    
    public var size: (SectionCollectionProtocol) -> CGSize
    
    public init(_ size: @escaping (SectionCollectionProtocol) -> CGSize) {
        self.size = size
    }
    
    public init(_ size: @escaping () -> CGSize) {
        self.size = { _ in
           return size()
        }
    }
    
}

public protocol SectionCollectionFlowLayoutSafeSizeProtocol: AnyObject {
    
    var sectionInset: UIEdgeInsets { get  }
    var sectionView: UICollectionView { get }
    var safeSize: SectionSafeSize { get set }
    func apply(safeSize: SectionSafeSize) -> Self
    
}

public extension SectionCollectionFlowLayoutSafeSizeProtocol {
    
    var defaultSafeSize: SectionSafeSize {
        SectionSafeSize({ [weak self] in
            guard let self = self else { return .zero }
            let sectionView = self.sectionView
            let sectionInset = self.sectionInset
            guard let flowLayout = sectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
                return sectionView.bounds.size
            }
            
            let size: CGSize
            switch flowLayout.scrollDirection {
            case .horizontal:
                 size = .init(width: sectionView.bounds.width,
                             height: sectionView.bounds.height
                                - sectionView.contentInset.top
                                - sectionView.contentInset.bottom
                                - sectionInset.top
                                - sectionInset.bottom)
            case .vertical:
                 size = .init(width: sectionView.bounds.width
                                - sectionView.contentInset.left
                                - sectionView.contentInset.right
                                - sectionInset.left
                                - sectionInset.right,
                             height: sectionView.bounds.height)
            @unknown default:
                 size = sectionView.bounds.size
            }
            assert(min(size.width, size.height) > 0, "无法取得正确的 size: \(size)")
            return size
        })
    }
    
    @discardableResult
    func apply(safeSize: SectionSafeSize) -> Self {
        self.safeSize = safeSize
        return self
    }
    
}
#endif
