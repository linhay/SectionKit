//
//  File.swift
//  
//
//  Created by linhey on 2022/8/11.
//

import UIKit

public class STCollectionManager {
    
    public lazy var sections: [STCollectionSectionProtocol] = []
    
    private lazy var delegate = STCollectionViewDelegateFlowLayout { [weak self] indexPath in
        self?.sections[indexPath.section] as? STCollectionViewDelegateFlowLayoutProtocol
    } endDisplaySection: { [weak self] indexPath in
        self?.sections[indexPath.section] as? STCollectionViewDelegateFlowLayoutProtocol
    } sections: { [weak self] in
        return self?.sections.lazy.compactMap({ $0 as? STCollectionViewDelegateFlowLayoutProtocol }) ?? []
    }
    
    private lazy var dataSource = STCollectionDataSource { [weak self] indexPath in
        self?.sections[indexPath.section]
    } sections: { [weak self] in
        self?.sections ?? []
    }
    
    private lazy var prefetching = STCollectionViewDataSourcePrefetching { [weak self] section in
        self?.sections[section] as? STCollectionViewDataSourcePrefetchingProtocol
    }
    
    public weak var sectionView: UICollectionView?
    
    private lazy var context = STCollectionSectionContext.SectionViewProvider(sectionView)

    public init(sectionView: UICollectionView) {
        self.sectionView = sectionView
        sectionView.delegate = delegate
        sectionView.dataSource = dataSource
        sectionView.prefetchDataSource = prefetching
    }
    
}

public extension STCollectionManager {
    
    func update(_ sections: [STCollectionSectionProtocol]) {
        guard let sectionView = sectionView else {
            return
        }
        
        context.sectionView = nil
        context = .init(sectionView)
        
        self.sections = sections.enumerated().map({ element in
            let section = element.element
            section.sectionState = .init(index: element.offset, sectionView: context)
            section.config(sectionView: sectionView)
            return section
        })
        
        sectionView.reloadData()
    }
    
}
