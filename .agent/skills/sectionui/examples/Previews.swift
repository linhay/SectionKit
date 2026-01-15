import SectionUI
import SwiftUI

#Preview("Standard Preview") {
    SKPreview.sections {
        ColorCell.wrapperToSingleTypeSection([.red, .yellow, .blue])
    }
}

#Preview("Adaptive Preview") {
    SKPreview.sections {
        AdaptiveTextCell.wrapperToSingleTypeSection([
            "Short text",
            "This is a longer text to demonstrate adaptive height in a preview environment.",
        ])
    }
}

#Preview("Cell States") {
    SKPreview.sections {
        AdaptiveTextCell.wrapperToSingleTypeSection {
            "Normal State"
            "An extremely long text that forces the cell to expand its height and potentially wrap multiple lines."
            "Selected State"
        }
    }
}
