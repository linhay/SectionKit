//
//  StandardCellViewController.swift
//  Example
//
//  Created by linhey on 1/2/25.
//

import SectionUI
import SnapKit
import UIKit

/// Lesson 1: Standard Code-Based Cell
///
/// Goal: Understand how to create a high-compatibility cell using `SKLoadViewProtocol` and `SKConfigurableView`.
///
/// Key Protocols:
/// - SKLoadViewProtocol: Defines sizing behavior (preferredSize).
/// - SKConfigurableView: Defines data binding (Model type and config method).

class StandardCellViewController: SKCollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lesson 1: Standard Cell"
        view.backgroundColor = .white

        let section = StandardCell.wrapperToSingleTypeSection([
            .red, .green, .blue, .yellow, .purple,
        ])

        manager.reload(section)
    }
}

class StandardCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {

    typealias Model = UIColor

    /// 1. Define the preferred size for the cell.
    /// This is called by the layout/manager to determine size before the cell is fully instantiated/displayed.
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return .init(width: size.width, height: 60)
    }

    /// 2. Configure the cell with data.
    func config(_ model: Model) {
        contentView.backgroundColor = model
    }
}
