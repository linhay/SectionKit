import Combine
import SectionUI
import UIKit

class PinnedSection: SKCSingleTypeSection<ColorCell> {

    private var cancellables = Set<AnyCancellable>()

    override init() {
        super.init()

        // Sticky Header with parallax-ready distance listening
        pinHeader { options in
            options.$distance.sink { value in
                // Transform header based on distance from top
            }.store(in: &self.cancellables)
        }

        // Make specific cell sticky (e.g. index 0)
        pinCell(at: 0) { options in
            // Cell sticky behavior
        }
    }
}
