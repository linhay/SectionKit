//
//  SKPublished.swift
//  Example
//
//  Created by linhey on 1/3/25.
//

import SwiftUI
import SectionUI
import Combine

class SKPublishedViewModel {
    
    @SKPublished
    var count = 0
    var cancellable: AnyCancellable?
    
    init() {}
    
}

struct SKPublishedView: View {
    
    @State var vm = SKPublishedViewModel()
    @State var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 64, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    var body: some View {
        VStack {
            SKUIView { context in
                label
            }
        }
        .task {
            vm.cancellable = vm.$count.bind { count in
                label.text = "\(count)"
            }
        }
        .ignoresSafeArea()
        .overlay(alignment: .bottom) {
            Button {
                vm.count += 1
            } label: {
                Text("Send")
                    .padding()
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
            }
        }
    }
    
}

#Preview {
    SKPublishedView()
}
