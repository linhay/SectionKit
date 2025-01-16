
/**
    网格布局
    1. 可以使用 cellSafeSize(_ kind: SKSafeSizeProviderKind, transforms: SKSafeSizeTransform) 来约束 Cell - preferredSize(limit size: CGSize, model: Model?) -> CGSize 函数中 size 的大小
    2. 也可以使用 Cell - preferredSize(limit size: CGSize, model: Model?) -> CGSize 直接返回 size 来实现
 */

import SectionUI
import SwiftUI
import Combine

struct GridColorView: View {
    
    let colors = [UIColor.red, .green, .blue, .yellow, .orange]
    @State
    var section = ColorCell
        .wrapperToSingleTypeSection()
        .setSectionStyle { section in
            section.minimumLineSpacing = 1
            section.minimumInteritemSpacing = 1
        }
        .cellSafeSize(.fraction(0.25), transforms: .height(asRatioOfWidth: 1))
    
    var body: some View {
        SKPreview.sections {
            section
        }
        .task {
            section.config(models: (0...50).map({ idx in
                    .init(text: idx.description, color: colors[idx % colors.count])
            }))
        }
        .ignoresSafeArea()
    }
    
}

#Preview {
    GridColorView()
}
