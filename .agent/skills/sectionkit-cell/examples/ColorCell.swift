import SectionUI
import UIKit

/// A simple cell created by code that displays a color.
class ColorCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {

    typealias Model = UIColor

    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return .init(width: size.width, height: 44)
    }

    func config(_ model: Model) {
        contentView.backgroundColor = model
    }
}
