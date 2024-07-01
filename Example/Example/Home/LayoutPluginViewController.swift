//
//  LayoutPluginViewController.swift
//  Example
//
//  Created by linhey on 2024/7/1.
//

import UIKit
import SectionUI

class LayoutPluginViewController: SKCollectionViewController {
    let size = CGSize(width: 60, height: 60)
    lazy var models = (0 ... 5).map { offset in
        ColorBlockCell.Model(color: .white, text: offset.description, size: size)
    }
    
    func leftSection() -> SKCSectionProtocol {
        SKCSingleTypeSection<ColorBlockCell>(models)
            .addLayoutPlugins(.left)
            .setSectionStyle([\.minimumInteritemSpacing, \.minimumLineSpacing], 12)
            .set(supplementary: .header, type: ReusableView.self, model: "left")
            .onCellAction(.selected) { context in
                context.delete()
            }
    }
    
    
    func rightSection() -> SKCSectionProtocol {
        SKCSingleTypeSection<ColorBlockCell>(models)
            .addLayoutPlugins(.right)
            .setSectionStyle([\.minimumInteritemSpacing, \.minimumLineSpacing], 12)
            .set(supplementary: .header, type: ReusableView.self, model: "right")
            .onCellAction(.selected) { context in
                context.insert(before: [.init(color: .red, text: "new", size: self.size)])
            }
    }
    
    func centerXSection() -> SKCSectionProtocol {
        SKCSingleTypeSection<ColorBlockCell>(models)
            .addLayoutPlugins(.centerX)
            .setSectionStyle([\.minimumInteritemSpacing, \.minimumLineSpacing], 12)
            .set(supplementary: .header, type: ReusableView.self, model: "centerX")
            .onCellAction(.selected) { context in
                context.insert(after: [.init(color: .red, text: "new", size: self.size)])
            }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        manager.reload([
            leftSection(),
            rightSection(),
            centerXSection()
        ])
    }
}
