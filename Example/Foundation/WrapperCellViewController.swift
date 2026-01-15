//
//  WrapperCellViewController.swift
//  Example
//
//  Created by linhey on 1/2/25.
//

import SectionUI
import SnapKit
import UIKit

/// Lesson 3: The Wrapper Pattern
///
/// Goal: Learn to use `SKWrapperView` to turn any `UIView` into a valid SectionKit cell without subclassing `UICollectionViewCell`.
///
/// Concept:
/// `SKWrapperView<View, Model>` acts as a bridge. It manages the `UICollectionViewCell` lifecycle and forwards configuration to your custom `UIView`.

class WrapperCellViewController: SKCollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Lesson 3: Wrapper Pattern"
        view.backgroundColor = .white

        // 1. Wrapping a standard UILabel
        // We define the View type (ConfigurableLabel) and the Model type (String).
        // SKCWrapperCell<ConfigurableLabel> creates a cell that hosts ConfigurableLabel.
        let labelSection = SKCWrapperCell<ConfigurableLabel>
            .wrapperToSingleTypeSection([
                "Hello",
                "World",
                "SectionKit",
            ])
            .setCellStyle { context in
                // Custom configuration block
                context.view.wrappedView.textAlignment = .center
                context.view.wrappedView.textColor = .black
                context.view.wrappedView.font = .boldSystemFont(ofSize: 18)
            }
            .cellSafeSize(.default, transforms: .fixed(height: 44))

        // 2. Wrapping a Custom View that conforms to SKConfigurableView
        // This is even cleaner as configuration is handled internally by SimpleColorView.
        // SKCWrapperCell<SimpleColorView> creates a cell that hosts SimpleColorView.
        let customViewSection = SKCWrapperCell<SimpleColorView>
            .wrapperToSingleTypeSection([.red, .blue, .green])

        manager.reload([labelSection, customViewSection])
    }
}

/// A simple UIView conforming to SKConfigurableView (not UICollectionViewCell)
class SimpleColorView: UIView, SKConfigurableView {
    typealias Model = UIColor

    func config(_ model: Model) {
        backgroundColor = model
        layer.cornerRadius = 8
    }

    // SKWrapperView uses this if available, or you can use .cellSafeSize on the section
    // If not provided, Wrapper might rely on constraints or default size.
    // SKWrapperView implementation usually handles sizing if the View conforms to SKLoadViewProtocol.
}

// Extending to support sizing if needed automatically
extension SimpleColorView: SKLoadViewProtocol {
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return CGSize(width: size.width, height: 60)
    }
}

/// A helper class to make UILabel adaptable for SectionKit
class ConfigurableLabel: UILabel, SKConfigurableView, SKLoadViewProtocol {
    typealias Model = String

    static func preferredSize(limit size: CGSize, model: String?) -> CGSize {
        return CGSize(width: size.width, height: 44)
    }

    func config(_ model: String) {
        text = model
    }
}
