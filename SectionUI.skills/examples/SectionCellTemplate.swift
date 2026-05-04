// MARK: - SectionCellTemplate
// A template for creating standard cells with manual size calculation.
// Use this when you need explicit control over cell sizing.

import SectionUI
import UIKit

/// A template for creating standard configurable cells.
/// Conforms to `SKConfigurableView` with manual `preferredSize` implementation.
final class SectionCellTemplate: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {

    // MARK: - Model

    /// The data model for configuring this cell.
    /// Replace with your actual model type.
    struct Model {
        let title: String
        let icon: UIImage?
    }

    // MARK: - Configuration

    /// Configures the cell with the provided model.
    /// - Parameter model: The data model containing the content to display.
    func config(_ model: Model) {
        titleLabel.text = model.title
        iconImageView.image = model.icon
        iconImageView.isHidden = model.icon == nil
    }

    // MARK: - SKConfigurableView

    /// Calculates the preferred size for the cell.
    /// - Parameters:
    ///   - size: The available size limit (usually the collection view width).
    ///   - model: The optional model to calculate size for.
    /// - Returns: The calculated size for the cell.
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        // Fixed height example:
        return CGSize(width: size.width, height: 56)

        // Dynamic height calculation example:
        // guard let model = model else { return CGSize(width: size.width, height: 56) }
        // let titleHeight = model.title.boundingRect(
        //     with: CGSize(width: size.width - 72, height: .greatestFiniteMagnitude),
        //     options: .usesLineFragmentOrigin,
        //     attributes: [.font: UIFont.preferredFont(forTextStyle: .body)],
        //     context: nil
        // ).height
        // return CGSize(width: size.width, height: max(56, titleHeight + 24))
    }

    // MARK: - UI Components

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .label
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .body)
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var accessoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "chevron.right")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .tertiaryLabel
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Private Methods

    private func setupUI() {
        contentView.addSubview(iconImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(accessoryImageView)

        NSLayoutConstraint.activate([
            iconImageView.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            iconImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: 24),
            iconImageView.heightAnchor.constraint(equalToConstant: 24),

            titleLabel.leadingAnchor.constraint(
                equalTo: iconImageView.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            titleLabel.trailingAnchor.constraint(
                equalTo: accessoryImageView.leadingAnchor, constant: -12),

            accessoryImageView.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
            accessoryImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            accessoryImageView.widthAnchor.constraint(equalToConstant: 12),
            accessoryImageView.heightAnchor.constraint(equalToConstant: 12),
        ])
    }
}

// MARK: - Usage Example
/*
 // Creating a section with standard cells:
 let section = SectionCellTemplate.wrapperToSingleTypeSection()
     .onCellAction(.selected) { context in
         print("Selected: \(context.model.title)")
     }

 section.config(models: [
     .init(title: "Settings", icon: UIImage(systemName: "gear")),
     .init(title: "Profile", icon: UIImage(systemName: "person.circle"))
 ])
 manager.reload(section)
 */
