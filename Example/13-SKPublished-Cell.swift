
//
//  SKPublished.swift
//  Example
//
//  Created by linhey on 1/3/25.
//

import SwiftUI
import SectionUI
import Combine

class PublishedCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    
    class Model {
        @SKPublished var isSelected: Bool = false
        init() {}
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return size
    }
    
    private var cancellables = Set<AnyCancellable>()
    func config(_ model: Model) {
        cancellables.removeAll()
        model.$isSelected.bind { [weak self] flag in
            guard let self = self else { return }
            UIView.animate(.easeOut) {
                self.layer.cornerRadius = flag ? 40 : 0
            }
        }.store(in: &cancellables)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.masksToBounds = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


struct SKPublishedViewCellView: View {
    @State
    private var section = PublishedCell
        .wrapperToSingleTypeSection()
        .setSectionStyle { section in
            section.minimumLineSpacing = 1
            section.minimumInteritemSpacing = 1
        }
        .cellSafeSize(.fraction(0.25), transforms: .height(asRatioOfWidth: 1))
        .onCellAction(.willDisplay, block: { context in
            let colors = [UIColor.red, .green, .blue, .yellow, .orange]
            context.view().backgroundColor = colors[context.row % colors.count]
        })
        .onCellAction(.selected) { context in
            context.model.isSelected.toggle()
        }
    
    var body: some View {
        SKPreview.sections {
            section
        }
        .task {
            section.config(models: (0...50).map({ idx in
                PublishedCell.Model()
            }))
        }
        .ignoresSafeArea()
    }
    
}

#Preview {
    SKPublishedViewCellView()
}
