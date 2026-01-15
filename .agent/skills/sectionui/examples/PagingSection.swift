import SectionUI
import UIKit

class PagingSection: SKCSingleTypeSection<ColorCell> {

    var isLoading = false

    override func item(willDisplay view: UICollectionViewCell, row: Int) {
        // Trigger preloading when reaching last 5 items
        if !isLoading, row + 5 >= models.count {
            loadMore()
        }
    }

    private func loadMore() {
        isLoading = true
        // API.fetch { [weak self] newItems in
        //     self?.insert(newItems)
        //     self?.isLoading = false
        // }
    }
}
