//
//  07-Decoration.swift
//  Example
//
//  Created by linhey on 1/3/25.
//

import SectionUI
import SwiftUI
import Combine

@Observable
class PinIndexReducer {
    @ObservationIgnored var cancellables = Set<AnyCancellable>()
    @ObservationIgnored lazy var section1 = ColorCell
        .wrapperToSingleTypeSection((0...10).map({ idx in
                .init(text: idx.description, color: .clear, alignment: .left)
        }))
        .cellSafeSize(.default, transforms: .fixed(height: 44))
        .setHeader(TextReusableView.self, model: .init(text: " Header 1", color: .clear, alignment: .center))
        .setFooter(TextReusableView.self, model: .init(text: " Footer 1", color: .clear, alignment: .right))
        .setSectionStyle(\.sectionInset, .init(top: 8, left: 0, bottom: 0, right: 0))
        .setAttributes(.reverseFooterAndSectionInset)
        .setAttributes(.reverseHeaderAndSectionInset)
    
    @ObservationIgnored lazy var section2 = ColorCell
        .wrapperToSingleTypeSection((0...10).map({ idx in
                .init(text: idx.description, color: .clear, alignment: .left)
        }))
        .cellSafeSize(.default, transforms: .fixed(height: 44))
        .setHeader(TextReusableView.self, model: .init(text: " Header 2", color: .clear, alignment: .center))
        .setFooter(TextReusableView.self, model: .init(text: " Footer 2", color: .clear, alignment: .right))
        .setSectionStyle(\.sectionInset, .init(top: 8, left: 0, bottom: 0, right: 0))
        .setAttributes(.reverseFooterAndSectionInset)
        .setAttributes(.reverseHeaderAndSectionInset)
    
    @ObservationIgnored lazy var section3 = ColorCell
        .wrapperToSingleTypeSection((0...100).map({ idx in
                .init(text: idx.description, color: .clear, alignment: .left)
        }))
        .cellSafeSize(.default, transforms: .fixed(height: 44))
        .setHeader(TextReusableView.self, model: .init(text: "Header 3", color: .clear, alignment: .center))
        .setFooter(TextReusableView.self, model: .init(text: "Footer 3", color: .clear, alignment: .right))
        .setSectionStyle(\.sectionInset, .init(top: 8, left: 0, bottom: 0, right: 0))
        .setAttributes(.reverseFooterAndSectionInset)
        .setAttributes(.reverseHeaderAndSectionInset)
    
    var controller = SKCollectionViewController()
        .backgroundColor(.clear)

    var section1CellDistance: CGFloat?
    var section2FooterDistance: CGFloat?
    var section3HeaderDistance: CGFloat?

    func reload() {
        section1.pinCell(at: 5) { options in
            options.$distance.sink { value in
                self.section1CellDistance = value
            }.store(in: &self.cancellables)
        }.store(in: &cancellables)
        section2.pinFooter { options in
            options.$distance.sink { value in
                self.section2FooterDistance = value
            }.store(in: &self.cancellables)
        }.store(in: &cancellables)
        section3.pinHeader { options in
            options.$distance.sink { value in
                self.section3HeaderDistance = value
            }.store(in: &self.cancellables)
        }.store(in: &cancellables)
        controller.reloadSections([section1, section2, section3])
    }
}

struct PinIndexView: View {
    
    @State var frame: CGRect = .zero
    @State var contentOffset: CGPoint = .zero
    @State var index: IndexPath = .init(row: 0, section: 0)
    @State private var store = PinIndexReducer()

    var body: some View {
        SKUIController {
            return store.controller
        }
        .background {
            LinearGradient(colors: [Color.white, Color.pink],
                           startPoint: .topLeading,
                           endPoint: .bottomLeading)
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(.green)
                .frame(height: 4)
        }
        .overlay(alignment: .topLeading) {
            HStack(alignment: .top) {
                rule(value: store.section1CellDistance, color: .black, text: "cell-5:")
                rule(value: store.section2FooterDistance, color: .yellow, text: "footer:")
                rule(value: store.section3HeaderDistance, color: .blue, text: "header:")
            }
        }
        .task {
            store.reload()
        }
    }
    
    @ViewBuilder
    func rule(value: CGFloat?, color: Color, text: String) -> some View {
        if value != nil {
            VStack(spacing: 0) {
                Rectangle()
                    .fill(color)
                    .frame(width: 32,height: 4)
                Rectangle()
                    .fill(color)
                    .frame(width: 1)
                Text("\(text) \(Int(value ?? 0))")
                    .monospaced()
                    .font(.footnote)
                    .padding(8)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.ultraThinMaterial)
                    }
                Rectangle()
                    .fill(color)
                    .frame(width: 1)
                Rectangle()
                    .fill(color)
                    .frame(width: 32,height: 4)
            }
            .frame(height: value)
        } else {
            EmptyView()
        }
    }
    
}

#Preview {
    PinIndexView()
}
