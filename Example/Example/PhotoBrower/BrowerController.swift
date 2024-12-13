//
//  BrowerController.swift
//  Example
//
//  Created by linhey on 11/27/24.
//

import SectionUI
import Foundation

class BrowerController: SKCollectionViewController {
    
    let section = (0...10)
        .map({ idx in
            BrowerPlaceHolderModel(id: idx.description)
        }) .map { model in
            BrowerZoomCell<BrowerLabelView>
                .wrapperToSingleTypeSection([.init(item: model, gestures: .init())])
                .onCellAction(.willDisplay) { context in
                    context.view().config(context.model)
                }
        }
    
    var index: Int = 0 {
        didSet {
            print(index)
        }
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionView.scrollDirection = .horizontal
        sectionView.isPagingEnabled = true
        sectionView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(-10)
        }
        
        manager.scroll(to: section[2], animated: false)
        manager.reload(section)

        manager.scrollObserver.add(scroll: "index") { handle in
            handle.didScroll { [weak self] scrollView in
                let itemW = scrollView.bounds.width
                guard let self = self, itemW.isNormal else { return }
                print("item:", itemW, scrollView.contentOffset.x)
                index = Int(scrollView.contentOffset.x / itemW)
            }
        }
    }

}
