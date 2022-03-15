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

public extension SectionTableProtocol {

    /// 注册 `LoadViewProtocol` 类型的 UICollectionViewCell
    ///
    /// - Parameter cell: UICollectionViewCell
    func register<T: UITableViewCell>(_ cell: T.Type) where T: LoadViewProtocol {
        if let nib = T.nib {
            sectionView.register(nib, forCellReuseIdentifier: T.identifier)
        } else {
            sectionView.register(T.self, forCellReuseIdentifier: T.identifier)
        }
    }

    func register<T: UITableViewHeaderFooterView>(_ view: T.Type, for kind: SupplementaryKind) where T: LoadViewProtocol {
        if let nib = T.nib {
            sectionView.register(nib, forHeaderFooterViewReuseIdentifier: T.identifier)
        } else {
            sectionView.register(T.self, forHeaderFooterViewReuseIdentifier: T.identifier)
        }
    }
    
    /// 从缓存池取出 Cell
    ///
    /// - Parameter indexPath: IndexPath
    /// - Returns: 具体类型的 `UITableViewCell`
    func dequeue<T: LoadViewProtocol>(at row: Int) -> T {
        if let cell = sectionView.dequeueReusableCell(withIdentifier: T.identifier, for: indexPath(from: row)) as? T {
            return cell
        }
        assertionFailure(String(describing: T.self))
        return sectionView.dequeueReusableCell(withIdentifier: T.identifier, for: indexPath(from: row)) as! T
    }
    
    /// 从缓存池取出 UITableViewHeaderFooterView
    ///
    /// - Returns: 具体类型的 `UITableViewCell`
    func dequeue<T: UITableViewHeaderFooterView>() -> T where T: LoadViewProtocol {
        return sectionView.dequeueReusableHeaderFooterView(withIdentifier: T.identifier) as! T
    }

}
#endif
