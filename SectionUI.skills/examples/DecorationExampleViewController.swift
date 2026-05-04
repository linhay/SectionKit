import SectionUI
import SnapKit
import UIKit

class DecorationExampleViewController: SKCollectionViewController {

    // 1. Simple Decoration Example
    private lazy var simpleSection = Cell.wrapperToSingleTypeSection()
        .setSectionStyle(\.sectionInset, .init(top: 10, left: 10, bottom: 10, right: 10))
        .set(decoration: SimpleDecorationView.self)

    // 2. Configurable Decoration Example
    private lazy var configSection = Cell.wrapperToSingleTypeSection()
        .setSectionStyle(\.sectionInset, .init(top: 10, left: 10, bottom: 10, right: 10))
        .set(decoration: ImageDecorationView.self, model: .typeA)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        // Configure Data
        simpleSection.config(models: (1...5).map { _ in .init(title: "Simple Decoration Item") })
        configSection.config(
            models: (1...5).map { _ in .init(title: "Configurable Decoration Item") })

        manager.reload([simpleSection, configSection])
    }

}
