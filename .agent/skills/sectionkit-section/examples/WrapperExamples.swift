import SectionUI
import UIKit

/// Demonstrates various ways to create sections using the wrapper utilities.
struct WrapperExamples {

    func examples() {
        let models = ["A", "B", "C"]

        // 1. Array-based
        let section1 = TextCell.wrapperToSingleTypeSection(models)

        // 2. DSL-based (Builder)
        let section2 = TextCell.wrapperToSingleTypeSection {
            "Item 1"
            "Item 2"
            if true {
                "Conditional Item"
            }
        }

        // 3. Single Item
        let section3 = TextCell.wrapperToSingleTypeSection("Only One")

        // 4. Empty section (ready for dynamic config)
        let section4 = TextCell.wrapperToSingleTypeSection()

        // 5. Advanced: Horizontal Nesting
        // This takes section1 and wraps it into a single cell that scrolls horizontally.
        let horizontal = section1.wrapperToHorizontalSection(height: 100)

        // 6. Production Chaining Pattern (Style + Action + Decoration)
        let productionSection = TextCell.wrapperToSingleTypeSection(models)
            .setSectionStyle(\.sectionInset, .init(top: 8, left: 16, bottom: 8, right: 16))
            .setCellStyle(
                .separator(.bottom(insets: .init(top: 0, left: 16, bottom: 0, right: 16)))
            )
            .onCellAction(.selected) { context in
                print("Logging exposure for \(context.model)")
            }
            .set(
                decoration: SectionCornerRadiusView.self,
                model: .init(backgroundColor: .white, cornerRadius: 12)
            )
            .addLayoutPlugins(.left)
    }

    // 7. Custom Style Chaining (Extension Pattern)
    func extensionExample(models: [String]) -> SKCSectionProtocol {
        return TextCell.wrapperToSingleTypeSection(models)
            .roundedCardStyle()
    }
    // 6. Async example
    func asyncExample() async throws -> SKCSectionProtocol {
        return try await TextCell.wrapperToSingleTypeSection {
            try await fetchDynamicModel()
        }
    }

    private func fetchDynamicModel() async throws -> String { "Fetched" }
}

class TextCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    typealias Model = String
    func config(_ model: String) {}
    static func preferredSize(limit size: CGSize, model: String?) -> CGSize { .zero }
}

/// Helper extension for consistent production styling.
extension SKCSingleTypeSection {
    func roundedCardStyle() -> Self {
        return
            self
            .setSectionStyle(\.sectionInset, .init(top: 8, left: 8, bottom: 0, right: 8))
            .set(
                decoration: SectionCornerRadiusView.self,
                model: .init(backgroundColor: .white, cornerRadius: 12))
    }
}
