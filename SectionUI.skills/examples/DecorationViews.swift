import SectionUI
import SnapKit
import UIKit

// Example 1: Simple Background Decoration
final class SimpleDecorationView: UICollectionReusableView, SKCDecorationView {

    override public init(frame: CGRect) {
        super.init(frame: frame)
        // Replaced custom Color with standard system color
        backgroundColor = .secondarySystemBackground
        layer.cornerRadius = 10
    }

    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

// Example 2: Configurable Decoration with Image
final class ImageDecorationView: UICollectionReusableView, SKCDecorationView, SKConfigurableView {

    // Define a Model
    enum Model {
        case typeA
        case typeB
    }

    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 12
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .tertiarySystemGroupedBackground
        layer.cornerRadius = 12
        layer.masksToBounds = true

        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.width.equalTo(150)  // Adjusted for generic example
            make.height.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func config(_ model: Model) {
        switch model {
        case .typeA:
            imageView.backgroundColor = .systemBlue.withAlphaComponent(0.2)
        case .typeB:
            imageView.backgroundColor = .systemGreen.withAlphaComponent(0.2)
        }
    }

}
