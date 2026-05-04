import SectionUI
import SnapKit
import UIKit

class BasicListViewController: SKCollectionViewController {

    // Create Section
    private lazy var section = Cell.wrapperToSingleTypeSection()
        .onCellAction(.selected) { context in
            print("Tapped: \(context.model.title)")
        }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        // Configure Data
        let models = (1...20).map { Model(title: "Item \($0)") }
        section.config(models: models)

        // Load into Manager
        manager.reload(section)
    }
}

class Cell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {

    // 1. Define Model
    struct Model {
        let title: String
    }

    // 2. Configure
    func config(_ model: Model) {
        label.text = model.title
    }

    // 3. Size Calculation
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return CGSize(width: size.width, height: 50)
    }

    // 4. Define View Elements
    private lazy var label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    // 5. Setup Layout
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        contentView.backgroundColor = .systemGray6
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
