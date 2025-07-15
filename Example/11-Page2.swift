//
//  10-Page.swift
//  Example
//
//  Created by linhey on 5/8/25.
//

import SwiftUI
import SectionUI
import Combine

private class Page2ChildController: UIViewController {
    
    let index: Int
    
    init(index: Int) {
        self.index = index
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Page2ChildController \(index) deinit")
    }
    
    private lazy var label: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 18, weight: .regular)
        view.textColor = .white
        view.textAlignment = .center
        view.backgroundColor = .black
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = [
            UIColor.red,
            .green,
            .blue,
            .yellow,
            .orange
        ][index % 5]
        label.text = "\(index)"
        view.addSubview(label)
        label.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
    }
    
}

struct Page2View: View {
    
    @State private var selection: Int = 0
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        SKUIController {
            let controller = SKPageViewController()
            controller.manager.spacing = 12
            controller.manager.$selection.removeDuplicates().dropFirst().sink { idx in
                self.selection = idx
            }.store(in: &controller.cancellables)
            controller.manager.childs = (0...50).map({ idx in
                    .init { content in
                        Page2ChildController(index: content.index)
                    }
            })
            return controller
        }
        .ignoresSafeArea()
        .overlay(alignment: .topLeading) {
            Text(selection.description)
                .padding()
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .safeAreaPadding()
        }
    }
    
}

#Preview {
    Page2View()
        .ignoresSafeArea()
}
