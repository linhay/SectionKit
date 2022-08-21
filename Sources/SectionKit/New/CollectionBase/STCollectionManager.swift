//
//  File.swift
//  
//
//  Created by linhey on 2022/8/11.
//

import UIKit

public class STCollectionManager {
    
    public lazy var sections: [SKCSectionProtocol] = []
    
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

public extension STCollectionManager {

    func update(_ section: SKCSectionProtocol) {
        update([section])
    }
    
    func update(_ sections: [SKCSectionProtocol]) {
        guard let sectionView = sectionView else {
            return
        }
        
        context.sectionView = nil
        context = .init(sectionView)
        
        self.sections = sections.enumerated().map({ element in
            let section = element.element
            section.sectionInjection = .init(index: element.offset, sectionView: context)
            section.config(sectionView: sectionView)
            return section
        })
        
        sectionView.reloadData()
    }
    
}
