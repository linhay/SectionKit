//
//  14-SKAdaptiveView.swift
//  Example
//
//  Created by linhey on 5/19/25.
//

import SwiftUI
import SectionUI
import Combine

/**
 # Cell 自动高度
 ## 让 Cell 遵守 `SKConfigurableAdaptiveMainView` 协议即可
 - SKConfigurableAdaptiveMainView 是 `SKConfigurableView` 的高级变体, 底层使用 `UIView.systemLayoutSizeFitting` 来自动计算高度.
 - tips: 可以进一步搭配高度缓存工具来来提升性能.
 ```swift
 SKAdaptiveCell
     .wrapperToSingleTypeSection()
     .highPerformanceID(by: \.model)
 ```
 */
final class SKAdaptiveCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableAdaptiveMainView {
    
    static let adaptive = SpecializedAdaptive()
    typealias Model = String
        
    func config(_ model: Model) {
        self.contentConfiguration = UIHostingConfiguration(content: {
            ZStack {
                Color.black.ignoresSafeArea()
                VStack {
                    Text(model)
                        .foregroundStyle(.white)
                }
            }
        })
        .margins(.vertical, 4)
        .margins(.horizontal, 0)
        .background(.clear)
    }
    
}


struct SKAdaptiveCellView: View {
    
    @State
    private var section = SKAdaptiveCell
        .wrapperToSingleTypeSection()
        .highPerformanceID(by: \.model)
    
    let models = [
        "2025-05-19T10:38:54+0800 error codes.vapor.application : error=RedisConnectionPoolError(baseError: RediStack.RedisConnectionPoolError.BaseError.poolClosed) [Queues] Job run failed",
        "Suite CompanyInformationJobTest passed after 556.816 seconds."
    ]
    
    var body: some View {
        VStack {
            SKPreview.sections {
                section
            }
            .onAppear {
                section.config(models: models.shuffled())
            }
            Button("reload") {
                section.config(models: models.shuffled())
            }
            .foregroundStyle(.white)
            .padding()
            .background {
                Capsule()
                    .fill(Color.black)
            }
        }

    }
    
}

#Preview {
    SKAdaptiveCellView()
}
