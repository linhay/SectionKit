import UIKit
import Combine

public final class SKPageManager: NSObject {
    
    public struct ChildContext: Identifiable {
        public let id: String
        public let index: Int
        public weak var controller: UIViewController?
        
        public init(id: String, index: Int, controller: UIViewController?) {
            self.id = id
            self.index = index
            self.controller = controller
        }
    }
    
    public struct Child: Identifiable {
        
        public let id: String
        public let maker: (_ context: ChildContext) -> UIViewController
        
        public static func withController(id: String, _ maker: @MainActor @escaping (_ context: ChildContext) -> UIViewController) -> Child {
            self.init(id: id, maker: maker)
        }
        
        public init(id: String, maker: @escaping (_ context: ChildContext) -> UIViewController) {
            self.id = id
            self.maker = maker
        }
        
        public init(id: String, maker: @escaping (_ context: ChildContext) -> UIView) {
            self.id = id
            self.maker = { context in
                SKPageViewBoxController(context: maker(context))
            }
        }
    }
    
    @SKPublished public var scrollDirection: UICollectionView.ScrollDirection = .horizontal
    @SKPublished public var spacing: CGFloat = 0
    @SKPublished public private(set) var childs = [Child]()
    var controllers: [String: SKWeakBox<SKPageChildController>] = [:]
    @SKPublished public var selection = 0
    @Published public var current: ChildContext?
    private weak var container: UIPageViewController?
    
    /// 是否已经绑定到 UI，只有在 makePageController() 后才为 true
    public private(set) var isBound: Bool = false
    private var isUpdatingSelection = false
    private var cancellables = Set<AnyCancellable>()
    /// 用于在 init 阶段就监听 selection 变化的订阅
    private var selectionCancellables = Set<AnyCancellable>()
    
    public override init() {
        super.init()
        setupCurrentBinding()
    }
    
    /// 设置 current 与 selection/childs 的绑定
    private func setupCurrentBinding() {
        // 监听 selection 或 childs 变化，更新 current（不依赖 controller）
        Publishers.CombineLatest($selection.eraseToAnyPublisher(), $childs.eraseToAnyPublisher())
            .sink { [weak self] selection, childs in
                guard let self = self else { return }
                self.updateCurrentFromSelection(selection, childs: childs)
            }
            .store(in: &selectionCancellables)
    }
    
    /// 根据 selection 更新 current，controller 可以为 nil
    private func updateCurrentFromSelection(_ selection: Int, childs: [Child]) {
        guard selection >= 0 && selection < childs.count else {
            current = nil
            return
        }
        let child = childs[selection]
        // 尝试获取已缓存的 controller（如果有的话）
        let cachedController = controllers[child.id]?.value?.model?.controller
        current = ChildContext(id: child.id, index: selection, controller: cachedController)
    }
}

public extension SKPageManager {
    
    /// 清理所有缓存的控制器
    func clearCache() {
        controllers.removeAll()
    }
    
    /// 解除 UI 绑定，清理所有订阅和缓存
    func unbind() {
        cancellables.removeAll()
        container = nil
        isBound = false
        clearCache()
    }
    
    /// 配置块，在绑定 UI 之前批量设置属性，避免多次触发更新
    @discardableResult
    func configure(_ block: (SKPageManager) -> Void) -> Self {
        block(self)
        return self
    }
    
    // MARK: - Childs Management
    
    /// 设置所有子页面
    @discardableResult
    func setChilds(_ childs: [Child]) -> Self {
        self.childs = childs
        return self
    }
    
    /// 添加单个子页面
    @discardableResult
    func addChild(_ child: Child) -> Self {
        childs.append(child)
        return self
    }
    
    /// 添加多个子页面
    @discardableResult
    func addChilds(_ childs: [Child]) -> Self {
        self.childs.append(contentsOf: childs)
        return self
    }
    
    /// 移除指定 id 的子页面
    @discardableResult
    func removeChild(id: String) -> Self {
        childs.removeAll { $0.id == id }
        return self
    }
    
    /// 移除指定索引的子页面
    @discardableResult
    func removeChild(at index: Int) -> Self {
        guard index >= 0 && index < childs.count else { return self }
        childs.remove(at: index)
        return self
    }
    
    /// 清空所有子页面
    @discardableResult
    func removeAllChilds() -> Self {
        childs.removeAll()
        return self
    }
    
    /// 替换指定索引的子页面
    @discardableResult
    func replaceChild(at index: Int, with child: Child) -> Self {
        guard index >= 0 && index < childs.count else { return self }
        childs[index] = child
        return self
    }
    
    /// 插入子页面到指定位置
    @discardableResult
    func insertChild(_ child: Child, at index: Int) -> Self {
        guard index >= 0 && index <= childs.count else { return self }
        childs.insert(child, at: index)
        return self
    }
    
}

extension SKPageManager {

    private func child(at index: Int, parent: UIViewController) -> UIViewController? {
        guard index >= 0 && index < childs.count else {
            return nil
        }
        
        let childModel = childs[index]
        if let box = controllers[childModel.id], let controller = box.value {
            return controller
        }
        
        let controller = childModel.maker(.init(id: childModel.id, index: index, controller: parent))
        let container = SKPageChildController()
        container.config(.init(id: childModel.id, index: index, controller: controller))
        controllers[childModel.id] = .init(container)
        return container
    }
    
    func makePageController() -> UIPageViewController {
        if let container {
            return container
        }
        
        cancellables.removeAll()
        isBound = false  // 重置状态
        
        let orientation: UIPageViewController.NavigationOrientation = (scrollDirection == .vertical) ? .vertical : .horizontal
        let controller = UIPageViewController(transitionStyle: .scroll, navigationOrientation: orientation, options: [
            .interPageSpacing: spacing,
        ])
        controller.dataSource = self
        controller.delegate = self
        
        // 设置初始页面
        if let initialChild = child(at: selection, parent: controller) {
            controller.setViewControllers([initialChild],
                                         direction: .forward,
                                         animated: false,
                                         completion: nil)
            // 更新 current 以包含新创建的 controller
            updateCurrentFromSelection(selection, childs: childs)
        }
        
        // 清理失效的缓存
        $childs.sink { [weak self] newChilds in
            guard let self = self else { return }
            let validIds = Set(newChilds.map(\.id))
            self.controllers = self.controllers.filter { validIds.contains($0.key) }
        }.store(in: &cancellables)
        
        // 监听 selection 变化，用户主动切换
        $selection.bind { [weak self, weak controller] newSelection in
            guard let self = self, let controller = controller else { return }
            guard !isUpdatingSelection else { return }
            
            // 检查是否需要切换
            let currentIndex = (controller.viewControllers?.first as? SKPageChildController)?.model?.index
            guard currentIndex != newSelection else { return }
            
            isUpdatingSelection = true
            defer { isUpdatingSelection = false }
            
            if let child = child(at: newSelection, parent: controller) {
                // 根据索引差判断滑动方向
                let direction: UIPageViewController.NavigationDirection = 
                    (currentIndex ?? 0) < newSelection ? .forward : .reverse
                
                controller.setViewControllers([child],
                                              direction: direction,
                                              animated: false,
                                              completion: nil)
                // 更新 current 以包含新创建的 controller
                self.updateCurrentFromSelection(newSelection, childs: self.childs)
            }
        }.store(in: &cancellables)
        
        container = controller
        isBound = true  // 标记为已经绑定
        return controller
    }
    
}

extension SKPageManager: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let controller = viewController as? SKPageChildController,
              let index = controller.model?.index else {
            return nil
        }
        return child(at: index - 1, parent: pageViewController)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let controller = viewController as? SKPageChildController,
              let index = controller.model?.index else {
            return nil
        }
        return child(at: index + 1, parent: pageViewController)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController,
                                   didFinishAnimating finished: Bool,
                                   previousViewControllers: [UIViewController],
                                   transitionCompleted completed: Bool) {
        guard completed,
              let controller = pageViewController.viewControllers?.first as? SKPageChildController,
              let model = controller.model else { return }
        
        guard !isUpdatingSelection else { return }
        
        isUpdatingSelection = true
        defer { isUpdatingSelection = false }
        
        // 设置 selection，current 会通过 setupCurrentBinding 自动更新
        selection = model.index
    }
}

open class SKPageViewController: UIViewController {
    
    public private(set) var manager = SKPageManager()
    public private(set) lazy var pageController = manager.makePageController()
    public var cancellables = Set<AnyCancellable>()
    
    private var reloadSubject = PassthroughSubject<Void, Never>()
    private var builtInCancellables = Set<AnyCancellable>()
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        set(manager: manager)
    }
    
   public func set(manager: SKPageManager) {
        self.manager = manager
        guard isViewLoaded else {
            return
        }
        builtInCancellables.removeAll()
        reloadSubject
            .throttle(for: .milliseconds(60), scheduler: RunLoop.main, latest: true)
            .sink { [weak self] in
                guard let self else { return }
                if !manager.childs.isEmpty {
                    renderUI()
                }
            }.store(in: &builtInCancellables)
       
       Publishers.MergeMany([manager.$scrollDirection.ignoreOutputType().eraseToAnyPublisher(),
                             manager.$spacing.ignoreOutputType().eraseToAnyPublisher(),
                             manager.$childs.ignoreOutputType().eraseToAnyPublisher()])
       .debounce(for: .milliseconds(60), scheduler: RunLoop.main)
       .sink { [weak self] _ in
           guard let self = self else { return }
           reloadSubject.send()
       }
       .store(in: &builtInCancellables)
    }
    
    open func renderUI() {
        pageController.removeFromParent()
        pageController.view.removeFromSuperview()
        pageController = manager.makePageController()
        addChild(pageController)
        view.addSubview(pageController.view)
        pageController.didMove(toParent: self)
        pageController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            pageController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

private class SKPageViewBoxController: UIViewController {
    
    let context: UIView
    
    init(context: UIView) {
        self.context = context
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(context)
        context.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            context.topAnchor.constraint(equalTo: view.topAnchor),
            context.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            context.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            context.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

}


public class SKPageChildController: UIViewController {
    
    public struct Model {
        public let id: String
        public let index: Int
        public var controller: UIViewController
    }
    
    public var model: Model?
    
    func config(_ model: Model) {
        // 清理旧的 controller
        if let oldController = self.model?.controller {
            oldController.willMove(toParent: nil)
            oldController.view.removeFromSuperview()
            oldController.removeFromParent()
        }
        
        self.model = model
        
        if isViewLoaded {
            let controller = model.controller
            addChild(controller)
            view.addSubview(controller.view)
            controller.didMove(toParent: self)
            controller.view.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                controller.view.topAnchor.constraint(equalTo: view.topAnchor),
                controller.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                controller.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                controller.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
            ])
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        if let model = model {
            config(model)
        }
    }
}
