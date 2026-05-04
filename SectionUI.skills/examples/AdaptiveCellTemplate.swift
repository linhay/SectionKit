// MARK: - AdaptiveCellTemplate
// A template for creating self-sizing cells using Auto Layout.
// The cell automatically calculates its size based on its content.

import SectionUI
import UIKit

/// A template for creating adaptive (self-sizing) cells.
/// Conforms to `SKConfigurableAdaptiveView` for automatic size calculation.
final class AdaptiveCellTemplate: UICollectionViewCell, SKLoadViewProtocol,
    SKConfigurableAdaptiveView
{

    // MARK: - Model

    /// The data model for configuring this cell.
    /// Replace `Any` with your actual model type.
    struct Model {
        let title: String
        let subtitle: String?
    }

    // MARK: - Configuration

    /// Configures the cell with the provided model.
    /// - Parameter model: The data model containing the content to display.
    func config(_ model: Model) {
        titleLabel.text = model.title
        subtitleLabel.text = model.subtitle
        subtitleLabel.isHidden = model.subtitle == nil
    }

    // MARK: - SKConfigurableAdaptiveView

    /// Configures the adaptive sizing behavior.
    /// - `direction`: The primary axis for sizing (`.vertical` for dynamic height, `.horizontal` for dynamic width).
    /// - `content`: Optional key path to a subview that drives the sizing (e.g., a UILabel or UIStackView).
    static var adaptive: SKAdaptive<AdaptiveCellTemplate> = .init(direction: .vertical)
    // Example with content key path:
    // static var adaptive: SKAdaptive<AdaptiveCellTemplate> = .init(direction: .vertical, content: \.titleLabel)

    // MARK: - UI Components

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .headline)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.leadingAnchor.constraint(
                equalTo: contentView.leadingAnchor, constant: 16),
            subtitleLabel.trailingAnchor.constraint(
                equalTo: contentView.trailingAnchor, constant: -16),
            subtitleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
        ])
    }
}

// MARK: - Usage Example
/*
 // Creating a section with adaptive cells:
 let section = AdaptiveCellTemplate.wrapperToSingleTypeSection()
 section.config(models: [
     .init(title: "Title 1", subtitle: "Subtitle 1"),
     .init(title: "Title 2", subtitle: nil)
 ])
 manager.reload(section)
 */
