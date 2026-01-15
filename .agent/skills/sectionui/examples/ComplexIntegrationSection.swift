import Combine
import SectionUI
import UIKit

/// A complex example demonstrating the integration of all Master Skills:
/// - Core Section (Shortcuts, Styling)
/// - Common (SKBinding, SKWhen)
/// - Layout (FlowLayout config)
/// - Interaction (Drag, ContextMenu)
class ComplexIntegrationSection: SKCSingleTypeSection<ComplexIntegrationSection.Cell> {

    // 1. Reactive State (sectionkit-common)
    @SKBinding var isEditing: Bool = false

    override init() {
        super.init()
        setupInteractions()
        setupLayout()
        setupBindings()

        // 2. Shortcut Syntax for Styling
        setSectionStyle(\.minimumLineSpacing, 12)
        setSectionStyle(\.sectionInset, .init(top: 10, left: 10, bottom: 10, right: 10))
    }

    // 3. Interactions (Drag & Drop, Context Menu)
    private func setupInteractions() {
        onCellShould(.move, true)  // Allow reordering

        onContextMenu { context in
            UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
                UIMenu(children: [
                    UIAction(title: "Delete", attributes: .destructive) { _ in
                        context.section.delete(context.row)
                    }
                ])
            }
        }
    }

    // 4. Advanced Layout (Sticky Headers)
    private func setupLayout() {
        // Safe casting to access FlowLayout properties
        if let layout = sectionView?.collectionViewLayout as? SKCollectionFlowLayout {
            layout.sectionHeadersPinToVisibleBounds = true
        }

        // SafeSize: 2 columns
        cellSafeSize(.fraction(0.5))
    }

    private func setupBindings() {
        // React to state changes
        $isEditing.changedPublisher.sink { [weak self] editing in
            self?.reload()  // or toggle cell states
        }.store(in: &cancellables)
    }

    class Cell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
        typealias Model = String

        func config(_ model: String) {
            contentView.backgroundColor = .secondarySystemBackground
            contentView.layer.cornerRadius = 8
        }

        static func preferredSize(limit size: CGSize, model: String?) -> CGSize {
            return CGSize(width: size.width, height: 80)
        }
    }
}
