import Combine
import SectionUI
import UIKit

/// Demonstrates advanced Selection capabilities.
class SelectionExample: SKCSingleTypeSection<SelectionExample.Cell> {

    // Define a custom Selection Style "Checkmark"
    // This allows us to separate selection logic from the cell itself
    struct CheckmarkStyle: SKSelectionStyle {
        func select(_ context: Context) {
            context.view.backgroundColor = .systemBlue.withAlphaComponent(0.2)
            context.view.layer.borderColor = UIColor.systemBlue.cgColor
            context.view.layer.borderWidth = 2
        }

        func deselect(_ context: Context) {
            context.view.backgroundColor = .systemBackground
            context.view.layer.borderColor = UIColor.clear.cgColor
            context.view.layer.borderWidth = 0
        }
    }

    override init() {
        super.init()
        setupSelection()
    }

    required init(_ models: [String] = []) {
        super.init(models)
        setupSelection()
    }

    private func setupSelection() {
        // 1. Enable Single Selection (Default)
        // sectionInjection?.selection.mode = .single

        // 2. Enable Multiple Selection
        sectionInjection?.selection.mode = .multiple

        // 3. Apply Selection Style
        // This automatically handles the visual updates when user taps
        selection.style = CheckmarkStyle()

        // 4. Listen to Selection Changes
        onCellAction(.selected) { context in
            print("Selected: \(context.model)")
        }

        onCellAction(.deselected) { context in
            print("Deselected: \(context.model)")
        }
    }

    class Cell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
        typealias Model = String

        private lazy var label: UILabel = {
            let label = UILabel()
            label.textAlignment = .center
            return label
        }()

        override init(frame: CGRect) {
            super.init(frame: frame)
            contentView.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                label.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                label.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            ])
            contentView.layer.cornerRadius = 8
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

        func config(_ model: String) {
            label.text = model
        }

        static func preferredSize(limit size: CGSize, model: String?) -> CGSize {
            return CGSize(width: size.width, height: 60)
        }
    }
}
