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

class SectionCollectionViewDataSource: NSObject, UICollectionViewDataSource {
        
    let sectionEvent = SectionDelegate<Int, SectionCollectionDriveProtocol>()
    let sectionsEvent = SectionDelegate<Void, LazyMapSequence<LazySequence<[SectionDynamicType]>.Elements, SectionCollectionDriveProtocol>>()
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sectionEvent.call(section)?.itemCount ?? 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return sectionEvent.call(indexPath.section)?.item(at: indexPath.item) ?? UICollectionViewCell()
    }

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return sectionsEvent.call()?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        return sectionEvent.call(indexPath.section)?.supplementary(kind: .init(rawValue: kind), at: indexPath.row) ?? UICollectionReusableView()
    }
    
    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return sectionEvent.call(indexPath.section)?.canMove(at: indexPath.item) ?? false
    }

    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if sourceIndexPath.section == destinationIndexPath.section {
            sectionEvent.call(sourceIndexPath.section)?.move(from: sourceIndexPath, to: destinationIndexPath)
        } else {
            sectionEvent.call(sourceIndexPath.section)?.move(from: sourceIndexPath, to: destinationIndexPath)
            sectionEvent.call(destinationIndexPath.section)?.move(from: sourceIndexPath, to: destinationIndexPath)
        }
    }
    
    public func indexTitles(for collectionView: UICollectionView) -> [String]? {
        sectionsEvent.call()?.compactMap(\.indexTitle)
    }

    public func collectionView(_ collectionView: UICollectionView, indexPathForIndexTitle title: String, at index: Int) -> IndexPath {
        return .init(row: 0, section: index)
    }

}
#endif
