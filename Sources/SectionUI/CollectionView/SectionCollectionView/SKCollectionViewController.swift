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
import SectionKit

open class SKCollectionViewController: UIViewController {
    
    public typealias ControllerStyleBlock  = (_ controller: SKCollectionViewController) -> Void
    public typealias SectionViewStyleBlock = (_ view: SKCollectionView) -> Void
    public typealias VoidAsyncAction = () async -> Void
    
    public class EndPoint {
        
        public var before: ControllerStyleBlock?
        public var after: ControllerStyleBlock?
        public var animate: ControllerStyleBlock?
        
        init(before: ControllerStyleBlock? = nil,
             after: ControllerStyleBlock? = nil,
             animate: ControllerStyleBlock? = nil) {
            self.before = before
            self.after = after
            self.animate = animate
        }
        
    }
    
    public class Events {
        public var viewDidLoad = [EndPoint]()
        public var viewDidAppear = [EndPoint]()
        public var viewTransition = [EndPoint]()
    }
    
    private var refreshableAction: VoidAsyncAction?
    
    public private(set) lazy var sectionView = SKCollectionView()
    public var manager: SKCManager { sectionView.manager }
    public let events: Events = .init()
        
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override open func viewDidLoad() {
        for event in events.viewDidLoad {
            event.before?(self)
        }
        super.viewDidLoad()
        if view.backgroundColor == nil {
            view.backgroundColor = .white
        }
        view.addSubview(sectionView)
        let safeArea = view.safeAreaLayoutGuide
        sectionView.translatesAutoresizingMaskIntoConstraints = false
        layout(anchor1: sectionView.topAnchor, anchor2: safeArea.topAnchor)
        layout(anchor1: sectionView.bottomAnchor, anchor2: view.bottomAnchor)
        layout(anchor1: sectionView.rightAnchor, anchor2: safeArea.rightAnchor)
        layout(anchor1: sectionView.leftAnchor, anchor2: safeArea.leftAnchor)
        
        for event in events.viewDidLoad {
            event.after?(self)
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        for event in events.viewDidAppear {
            event.before?(self)
        }
        super.viewDidAppear(animated)
        for event in events.viewDidAppear {
            event.after?(self)
        }
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sectionView.collectionViewLayout.invalidateLayout()
    }
    
    override open func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        for event in events.viewTransition {
            event.before?(self)
        }
        super.viewWillTransition(to: size, with: coordinator)
        guard isViewLoaded else {
            return
        }
#if targetEnvironment(macCatalyst)
        sectionView.collectionViewLayout.invalidateLayout()
        return
#endif
        coordinator.animate { [weak self] context in
            guard let self = self else { return }
            view.bounds.size.width = size.width
            sectionView.collectionViewLayout.invalidateLayout()
            for event in events.viewTransition {
                event.animate?(self)
            }
        } completion: { [weak self] context in
            guard let self = self else { return }
            view.bounds.size.width = size.width
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                sectionView.collectionViewLayout.invalidateLayout()
                for event in events.viewTransition {
                    event.after?(self)
                }
            }
        }
    }
    
}

public extension SKCollectionViewController {
    
    func onAppear(perform action: (() -> Void)? = nil) -> Self {
        events.viewDidAppear.append(.init(after: { controller in
            action?()
        }))
        return self
    }
    
}

public extension SKCollectionViewController {
    
    func refreshable(action: @escaping VoidAsyncAction) -> Self {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshAction), for: .valueChanged)
        sectionView.refreshControl = refreshControl
        self.refreshableAction = action
        return self
    }

    @objc private func refreshAction() {
        Task { @MainActor in
            await refreshableAction?()
            sectionView.refreshControl?.endRefreshing()
        }
    }
    
}

public extension SKCollectionViewController {
    
    func controllerStyle(_ block: @escaping ControllerStyleBlock) -> Self {
        events.viewDidLoad.append(.init(after: block))
        return self
    }
    
    func sectionViewStyle(_ block: @escaping SectionViewStyleBlock) -> Self {
        events.viewDidLoad.append(.init(after: { controller in
            block(controller.sectionView)
        }))
        return self
    }
    
    func reloadSections(_ section: any SKCBaseSectionProtocol) -> Self {
        return reloadSections([section])
    }
    
    func reloadSections(_ section: [any SKCBaseSectionProtocol]) -> Self {
        return controllerStyle { controller in
            controller.manager.reload(section)
        }
    }
    
}

private extension SKCollectionViewController {
    
    func layout(anchor1: NSLayoutYAxisAnchor, anchor2: NSLayoutYAxisAnchor) {
        let constraint = anchor1.constraint(equalTo: anchor2)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }
    
    func layout(anchor1: NSLayoutXAxisAnchor, anchor2: NSLayoutXAxisAnchor) {
        let constraint = anchor1.constraint(equalTo: anchor2)
        constraint.priority = .defaultLow
        constraint.isActive = true
    }
    
}
#endif
