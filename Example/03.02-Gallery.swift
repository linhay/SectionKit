//
//  03.01-Gallery.swift
//  Example
//
//  Created by linhey on 6/16/25.
//

import SwiftUI
import SectionUI

@Observable
class GalleryReducer {
    
    @ObservationIgnored var models = (0...20000).map { idx in
        let colors = [UIColor.red, .green, .blue, .yellow, .orange]
        return ColorCell.Model.init(text: idx.description, color: colors[idx % colors.count].withAlphaComponent(0.5))
    }
    
    @ObservationIgnored var sectionController = SKCollectionViewController()
    @ObservationIgnored var section = ColorCell
        .wrapperToSingleTypeSection()
        .setSectionStyle { section in
            section.minimumLineSpacing = 1
            section.minimumInteritemSpacing = 1
            section.feature.skipDisplayEventWhenFullyRefreshed = true
        }
        .cellSafeSize(.fraction(0.25), transforms: .height(asRatioOfWidth: 1))
    
    
    func reload() {
        let sections = SKPerformance.shared.duration {
            models.map({ model in
                ColorCell.wrapperToSingleTypeSection(model)
            })
        }
        SKPerformance.shared.duration {
            sectionController.reloadSections(sections)
        }
    }
    
}

struct GalleryView: View {
    
    @State var store: GalleryReducer
    
    var body: some View {
        VStack {
            SKUIController {
                store.sectionController
            }
            
            Button("reload") {
                store.reload()
            }
        }
    }
    
}

#Preview {
    @Previewable @State var store = GalleryReducer()
    GalleryView(store: store)
}
