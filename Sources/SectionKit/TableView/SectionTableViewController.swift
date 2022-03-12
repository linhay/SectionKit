// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if canImport(UIKit)
import UIKit

open class SectionTableViewController: UIViewController {

    open lazy var sectionView = SectionTableView(frame: .zero, style: style)
    open lazy var manager = SectionTableManager(sectionView: sectionView)
    private let style: UITableView.Style

    public init(style: UITableView.Style = .grouped) {
        self.style = style
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        self.style = .plain
        super.init(coder: coder)
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        if view.backgroundColor == nil {
            view.backgroundColor = .white
        }
        view.addSubview(sectionView)
        let safeArea = view.safeAreaLayoutGuide
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        layout(anchor1: sectionView.topAnchor, anchor2: safeArea.topAnchor)
        layout(anchor1: sectionView.bottomAnchor, anchor2: safeArea.bottomAnchor)
        layout(anchor1: sectionView.rightAnchor, anchor2: safeArea.rightAnchor)
        layout(anchor1: sectionView.leftAnchor, anchor2: safeArea.leftAnchor)
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate { [weak self] context in
            self?.sectionView.reloadData()
        } completion: { [weak self] context in
            self?.sectionView.reloadData()
        }
    }

    private func layout(anchor1: NSLayoutYAxisAnchor, anchor2: NSLayoutYAxisAnchor) {
        let constraint = anchor1.constraint(equalTo: anchor2)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }

    private func layout(anchor1: NSLayoutXAxisAnchor, anchor2: NSLayoutXAxisAnchor) {
        let constraint = anchor1.constraint(equalTo: anchor2)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }

}
#endif
