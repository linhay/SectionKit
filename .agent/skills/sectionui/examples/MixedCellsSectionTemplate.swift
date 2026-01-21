// MARK: - MixedCellsSectionTemplate
// A template for creating sections that display multiple types of cells.
// Use this when you need heterogeneous cell layouts in a single section.

import SectionUI
import UIKit

/// A template for creating sections with multiple cell types.
/// Directly conforms to `SKCSectionProtocol` for maximum flexibility.
class MixedCellsSectionTemplate: SKCSectionProtocol, SKSafeSizeProviderProtocol {

    // MARK: - Cell Types

    /// Enum representing the different cell types in this section.
    /// Each case holds the model data for that cell type.
    enum CellType {
        case header(HeaderCell.Model)
        case item(ItemCell.Model)
        case footer(FooterCell.Model)
    }

    // MARK: - SKCSectionProtocol

    var sectionInjection: SKCSectionInjection?
    lazy var safeSizeProvider: SKSafeSizeProvider = defaultSafeSizeProvider

    /// The list of cell types to display.
    var cellTypes: [CellType] = []

    /// The number of items in this section.
    var itemCount: Int { cellTypes.count }

    // MARK: - Initialization

    /// Creates a new section with the given cell types.
    /// - Parameter cellTypes: The array of cell types to display.
    init(cellTypes: [CellType] = []) {
        self.cellTypes = cellTypes
    }

    // MARK: - Configuration

    /// Registers the cell classes with the collection view.
    /// Called automatically when the section is added to a manager.
    func config(sectionView: UICollectionView) {
        register(HeaderCell.self)
        register(ItemCell.self)
        register(FooterCell.self)
    }

    // MARK: - Size Calculation

    /// Returns the size for the cell at the given row.
    func itemSize(at row: Int) -> CGSize {
        switch cellTypes[row] {
        case .header(let model):
            return HeaderCell.preferredSize(limit: safeSizeProvider.size, model: model)
        case .item(let model):
            return ItemCell.preferredSize(limit: safeSizeProvider.size, model: model)
        case .footer(let model):
            return FooterCell.preferredSize(limit: safeSizeProvider.size, model: model)
        }
    }

    // MARK: - Cell Dequeuing

    /// Returns the configured cell for the given row.
    func item(at row: Int) -> UICollectionViewCell {
        switch cellTypes[row] {
        case .header(let model):
            let cell = dequeue(at: row) as HeaderCell
            cell.config(model)
            return cell
        case .item(let model):
            let cell = dequeue(at: row) as ItemCell
            cell.config(model)
            return cell
        case .footer(let model):
            let cell = dequeue(at: row) as FooterCell
            cell.config(model)
            return cell
        }
    }

    // MARK: - Selection Handling

    /// Handles cell selection at the given row.
    func item(selected row: Int) {
        switch cellTypes[row] {
        case .header:
            // Header tapped
            break
        case .item(let model):
            // Item tapped - handle action
            print("Item selected: \(model)")
        case .footer:
            // Footer tapped
            break
        }
    }
}

// MARK: - Example Cell Definitions

/// A header cell for the mixed section.
final class HeaderCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {

    struct Model {
        let title: String
    }

    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return CGSize(width: size.width, height: 44)
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    func config(_ model: Model) {
        titleLabel.text = model.title
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// An item cell for the mixed section.
final class ItemCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {

    struct Model {
        let title: String
        let subtitle: String?
    }

    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return CGSize(width: size.width, height: 60)
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .caption1)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    func config(_ model: Model) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// A footer cell for the mixed section.
final class FooterCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {

    struct Model {
        let text: String
    }

    func config(_ model: Model) {
        textLabel.text = model.text
    }

    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return CGSize(width: size.width, height: 32)
    }

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .footnote)
        label.textColor = .tertiaryLabel
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(textLabel)
        NSLayoutConstraint.activate([
            textLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Usage Example
/*
 // Creating a mixed section:
 let section = MixedCellsSectionTemplate(cellTypes: [
     .header(.init(title: "Section Header")),
     .item(.init(title: "Item 1", subtitle: "Description 1")),
     .item(.init(title: "Item 2", subtitle: "Description 2")),
     .item(.init(title: "Item 3", subtitle: nil)),
     .footer(.init(text: "3 items"))
 ])
 manager.reload(section)
 */
