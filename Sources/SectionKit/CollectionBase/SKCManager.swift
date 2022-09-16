//
//  File.swift
//  
//
//  Created by linhey on 2022/8/11.
//

import UIKit

public class SKCManager {
    
    public lazy var sections: [SKCBaseSectionProtocol] = []
    
    private lazy var delegate = SKCViewDelegateFlowLayout { [weak self] indexPath in
        self?.sections[indexPath.section] as? SKCViewDelegateFlowLayoutProtocol
    } endDisplaySection: { [weak self] indexPath in
        self?.sections[indexPath.section] as? SKCViewDelegateFlowLayoutProtocol
    } sections: { [weak self] in
        return self?.sections.lazy.compactMap({ $0 as? SKCViewDelegateFlowLayoutProtocol }) ?? []
    }
    
    private lazy var dataSource = SKCDataSource { [weak self] indexPath in
        self?.sections[indexPath.section]
    } sections: { [weak self] in
        self?.sections ?? []
    }
    
    private lazy var prefetching = SKCViewDataSourcePrefetching { [weak self] section in
        self?.sections[section] as? SKCViewDataSourcePrefetchingProtocol
    }
    
    public weak var sectionView: UICollectionView?
    
    private lazy var context = SKCSectionInjection.SectionViewProvider(sectionView)

    public init(sectionView: UICollectionView) {
        self.sectionView = sectionView
        sectionView.delegate = delegate
        sectionView.dataSource = dataSource
        sectionView.prefetchDataSource = prefetching
    }
    
}

public extension SKCManager {

    func reload(_ section: SKCBaseSectionProtocol) {
        reload([section])
    }
    
    func reload(_ sections: [SKCBaseSectionProtocol]) {
        guard let sectionView = sectionView else {
            return
        }
        
        context.sectionView = nil
        context = .init(sectionView)
        
        self.sections = sections.enumerated().map({ element in
            let section = element.element
            section.sectionInjection = .init(index: element.offset, sectionView: context)
                .reset([
                    .reload: { [weak self] injection in
                        guard let self = self else { return }
                        self.sectionView?.reloadSections(IndexSet(integer: injection.index))
                    },
                    .delete: { [weak self] injection in
                        guard let self = self else { return }
                        self.sectionView?.deleteSections(IndexSet(integer: injection.index))
                    }
                ])
            section.config(sectionView: sectionView)
            return section
        })
        
        sectionView.reloadData()
    }
    
}
