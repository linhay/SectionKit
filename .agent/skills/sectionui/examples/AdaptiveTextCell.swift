import SectionUI
import SwiftUI
import UIKit

/// A cell that uses SwiftUI for its content and adapts its height automatically.
final class AdaptiveTextCell: UICollectionViewCell, SKLoadViewProtocol,
    SKConfigurableAdaptiveMainView
{

    static let adaptive = SpecializedAdaptive()
    typealias Model = String

    func config(_ model: Model) {
        self.contentConfiguration = UIHostingConfiguration(content: {
            Text(model)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
        })
        .margins(.all, 0)
    }
}
