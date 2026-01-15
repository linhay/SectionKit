import Combine
import SectionUI
import UIKit

/// Demonstrates advanced interactive features: Drag & Drop, Context Menu, and Prefetching.
class AdvancedInteractionSection: SKCSingleTypeSection<AdvancedInteractionSection.Cell> {

    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        setupInteractions()
        setupPrefetching()
    }

    required init(_ models: [String] = []) {
        super.init(models)
        setupInteractions()
        setupPrefetching()
    }

    private func setupInteractions() {
        // 1. Enable Drag & Drop (Reordering)
        onCellShould(.move) { context in
            // Only allow moving if the string length is > 1 (Example condition)
            return context.model.count > 1
        }

        // 2. Context Menu (Long Press)
        onContextMenu { context in
            return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                UIMenu(
                    title: "Actions for \(context.model)",
                    children: [
                        UIAction(
                            title: "Delete", image: UIImage(systemName: "trash"),
                            attributes: .destructive
                        ) { _ in
                            context.section.delete(context.row)
                        },
                        UIAction(title: "Check Length", image: UIImage(systemName: "info.circle")) {
                            _ in
                            print("Length: \(context.model.count)")
                        },
                    ])
            }
        }
    }

    private func setupPrefetching() {
        // 3. Advanced Prefetching Monitoring
        prefetch.prefetchPublisher
            .sink { [weak self] rows in
                print("Prefetching rows: \(rows)")
                // Logic to load more data if needed
            }
            .store(in: &cancellables)
    }

    // Simple Cell for demonstration
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
            contentView.backgroundColor = .systemGray6
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
