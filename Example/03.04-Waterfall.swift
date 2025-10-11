
//
//  03.01-Gallery.swift
//  Example
//
//  Created by linhey on 6/16/25.
//

import SwiftUI
import SectionUI
import UIKit

final class WaterfallCell: UICollectionViewCell, SKConfigurableView, SKLoadViewProtocol {
    
    typealias Model = CGFloat
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return .init(width: size.width, height: model ?? 44)
    }

    func config(_ model: Model) {
        label.text = model.description
    }
    
    private lazy var label: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18, weight: .regular)
        view.textColor = .black
        view.textAlignment = .center
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        contentView.backgroundColor = .lightGray
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 4
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}



@Observable
class WaterfallReducer {
    
    @ObservationIgnored var sectionController = SKCollectionViewController()
        .sectionViewStyle { view in
            let layout = SKWaterfallLayout()
            layout.columnWidthRatios = [0.5, 0.5]
            view.setCollectionViewLayout(layout, animated: false)
        }
    
    @ObservationIgnored lazy var section1 = WaterfallCell
        .wrapperToSingleTypeSection()
        .cellSafeSize(.fraction(0.5))
        .setSectionStyle([\.minimumLineSpacing, \.minimumInteritemSpacing], 12)
        .setSectionStyle(\.sectionInset, .init(top: 8, left: 8, bottom: 8, right: 8))
        .setHeader(TextReusableView.self, model: .init(text: "Header 1", color: .green))
        .setFooter(TextReusableView.self, model: .init(text: "Footer 1", color: .green))
    
    @ObservationIgnored lazy var section2 = WaterfallCell
        .wrapperToSingleTypeSection()
        .cellSafeSize(.fraction(0.5))
        .setSectionStyle([\.minimumLineSpacing, \.minimumInteritemSpacing], 12)
        .setSectionStyle(\.sectionInset, .init(top: 8, left: 8, bottom: 8, right: 8))
        .setHeader(TextReusableView.self, model: .init(text: "Header 2", color: .green))
        .setFooter(TextReusableView.self, model: .init(text: "Footer 2", color: .green))
    
    func reload() {
       let models = (0...100)
            .map({ _ in CGFloat(Int.random(in: 44...200)) })
        section1.config(models: models)
        section2.config(models: models)
        sectionController.reloadSections([section1, section2])
    }
    
}

struct WaterfallView: View {
    
    @State var store: WaterfallReducer = WaterfallReducer()
    
    var body: some View {
        VStack {
            SKUIController {
                store
                    .sectionController
                    .backgroundColor(.yellow)
            }
            .ignoresSafeArea()
            Button("reload") {
                store.reload()
            }
        }
        .task {
            store.reload()
        }
    }
    
}

#Preview {
    @Previewable @State var store = AquamanReducer()
    AquamanView(store: store)
}
