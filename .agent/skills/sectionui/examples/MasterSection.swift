import Combine
import SectionUI
import UIKit

/// A production-ready section with diffing, performance caching, and styling.
class MasterSection: SKCSingleTypeSection<ColorCell> {

    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()
        setup()
    }

    private func setup() {
        // 1. Style Delegate for UI customization
        setItemStyleEvent.delegate(on: self) { (self, context) in
            context.cell.layer.cornerRadius = 12
            context.cell.clipsToBounds = true
        }

        // 2. Event Handling
        onCellAction(.selected) { context in
            print("Selected: \(context.model.text)")
        }

        // 3. Supplementary Views
        setHeader(TextReusableView.self, model: "Section Title") { header in
            header.config("Section Title")
        }
    }

    // 4. Differential Updates
    override func apply(_ models: [ColorCell.Model]) {
        if self.models.isEmpty || models.isEmpty {
            super.apply(models)
        } else {
            let difference = models.difference(from: self.models)
            pick {
                for change in difference {
                    switch change {
                    case .remove(let offset, _, _): delete(offset)
                    case .insert(let offset, let element, _): insert(at: offset, element)
                    }
                }
            }
        }
    }

    // 5. Performance Caching
    override func itemSize(at row: Int) -> CGSize {
        guard let model = models.value(at: row) else { return .zero }
        return highPerformance.cache(by: model, limit: safeSizeProvider.size) { limit in
            ColorCell.preferredSize(limit: limit, model: model)
        }
    }
}
