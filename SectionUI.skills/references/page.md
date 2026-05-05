# Page View Controller (页面视图控制器)

`SKPageViewController` 和 `SKPageManager` 提供响应式的页面管理功能。

## SKPageManager - 页面管理器

管理多个页面（ViewController）的显示和切换。

### 基础用法

```swift
let pageManager = SKPageManager()
    .setChilds([
        .init(id: "page1") { context in
            let vc = Page1ViewController()
            return vc
        },
        .init(id: "page2") { context in
            let vc = Page2ViewController()
            return vc
        },
        .init(id: "page3") { context in
            let vc = Page3ViewController()
            return vc
        }
    ])
    .configure { manager in
        manager.scrollDirection = .horizontal
        manager.spacing = 16
    }
```

### 配置选项

```swift
pageManager.configure { manager in
    // 滚动方向
    manager.scrollDirection = .horizontal  // 或 .vertical
    
    // 页面间距
    manager.spacing = 20
}
```

### 双向绑定

使用 `@Published` 属性进行双向绑定：

```swift
class MyViewController: UIViewController {
    
    private let pageManager = SKPageManager()
    
    @Published var currentPage: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 监听页面变化
        pageManager.$current
            .compactMap { $0 }
            .sink { [weak self] page in
                print("切换到页面: \(page.id)")
                self?.updateIndicator(page)
            }
            .store(in: &cancellables)
        
        // 外部控制页面切换
        $currentPage
            .sink { [weak self] index in
                self?.pageManager.selection = index
            }
            .store(in: &cancellables)
    }
}
```

### 页面操作

```swift
// 切换到指定页面
pageManager.selection = 1

// 获取当前页面
if let current = pageManager.current {
    print("当前页面 ID: \(current.id)")
}

// 动态添加页面
pageManager.addChild(.init(id: "newPage") { _ in NewViewController() })

// 插入页面
pageManager.insertChild(.init(id: "insertedPage") { _ in InsertedVC() }, at: 1)

// 移除页面
pageManager.removeChild(at: 2)
```

## SKPageViewController - 页面容器

将 `SKPageManager` 包装为 ViewController。

### 基础用法

```swift
let pageVC = SKPageViewController()
pageVC.set(manager: pageManager)

// 添加到视图层级
addChild(pageVC)
view.addSubview(pageVC.view)
pageVC.didMove(toParent: self)
```

### 配置布局

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    
    let pageVC = SKPageViewController()
    pageVC.set(manager: pageManager)
    addChild(pageVC)
    view.addSubview(pageVC.view)
    
    pageVC.view.snp.makeConstraints { make in
        make.edges.equalToSuperview()
    }
    
    pageVC.didMove(toParent: self)
}
```

## 实战示例

### 示例 1：Tab 式分页

参考 `Example/Page/PageViewController.swift`：

```swift
class TabPageViewController: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    private lazy var pageManager: SKPageManager = {
        let manager = SKPageManager()
        manager.setChilds([
            .init(id: "home") { _ in HomeViewController() },
            .init(id: "discover") { _ in DiscoverViewController() },
            .init(id: "profile") { _ in ProfileViewController() }
        ])
        manager.configure { $0.scrollDirection = .horizontal }
        return manager
    }()
    
    private lazy var segmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["首页", "发现", "我的"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置导航栏
        navigationItem.titleView = segmentedControl
        
        // 添加页面容器
        let pageVC = SKPageViewController()
        pageVC.set(manager: pageManager)
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view.frame = view.bounds
        pageVC.didMove(toParent: self)
        
        // 监听页面变化，同步到 SegmentedControl
        pageManager.$current
            .compactMap { $0 }
            .sink { [weak self] page in
                self?.segmentedControl.selectedSegmentIndex = page.index
            }
            .store(in: &cancellables)
    }
    
    @objc private func segmentChanged() {
        pageManager.selection = segmentedControl.selectedSegmentIndex
    }
}
```

### 示例 2：引导页

```swift
class OnboardingViewController: UIViewController {
    
    private lazy var pageManager: SKPageManager = {
        let manager = SKPageManager()
        manager.setChilds([
            .init(id: "1") { _ in OnboardingPage(imageName: "onboarding1") },
            .init(id: "2") { _ in OnboardingPage(imageName: "onboarding2") },
            .init(id: "3") { _ in OnboardingPage(imageName: "onboarding3") }
        ])
        manager.configure { manager in
            manager.scrollDirection = .horizontal
        }
        return manager
    }()
    
    private lazy var pageControl: UIPageControl = {
        let control = UIPageControl()
        control.numberOfPages = 3
        control.currentPage = 0
        return control
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 添加页面
        let pageVC = SKPageViewController()
        pageVC.set(manager: pageManager)
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view.frame = view.bounds
        pageVC.didMove(toParent: self)
        
        // 添加页面指示器
        view.addSubview(pageControl)
        pageControl.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).offset(-32)
        }
        
        // 同步页面指示器
        pageManager.$current
            .compactMap { $0?.index }
            .assign(to: \.currentPage, on: pageControl)
            .store(in: &cancellables)
        
        // 最后一页显示开始按钮
        pageManager.$current
            .compactMap { $0?.index }
            .sink { [weak self] index in
                self?.showStartButton(index == 2)
            }
            .store(in: &cancellables)
    }
    
    private func showStartButton(_ show: Bool) {
        // 显示/隐藏开始按钮
    }
}
```

### 示例 3：嵌套滚动

参考 `Example/Page/NestedScrollViewController.swift`：

```swift
class NestedScrollViewController: UIViewController {
    
    // 外层：垂直滚动的主容器
    private lazy var outerScrollView = UIScrollView()
    
    // 内层：水平滚动的页面
    private lazy var pageManager: SKPageManager = {
        let manager = SKPageManager()
        manager.configure { $0.scrollDirection = .horizontal }
        return manager
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(outerScrollView)
        outerScrollView.frame = view.bounds
        
        // 添加头部内容
        let headerView = createHeaderView()
        outerScrollView.addSubview(headerView)
        
        // 添加页面容器
        let pageVC = SKPageViewController()
        pageVC.set(manager: pageManager)
        addChild(pageVC)
        outerScrollView.addSubview(pageVC.view)
        
        // 布局
        headerView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.width.equalTo(view.snp.width)
            make.height.equalTo(200)
        }
        
        pageVC.view.snp.makeConstraints { make in
            make.top.equalTo(headerView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.width.equalTo(view.snp.width)
            make.height.equalTo(view.snp.height)
        }
        
        pageVC.didMove(toParent: self)
        
        // 配置 contentSize
        outerScrollView.contentSize = CGSize(
            width: view.bounds.width,
            height: 200 + view.bounds.height
        )
    }
}
```

## SKZoomableScrollView

可缩放的滚动视图，常与 PageViewController 配合使用。

更精确的 sizing、tap、pan-to-dismiss 与 gesture 语义见 `page-zoom-recipes.md`。

### 基础用法

```swift
final class ImageContentView: UIImageView, SKZoomableContentView {
    let zoomableContext = SKZoomableContext()
}

let imageView = ImageContentView()
imageView.zoomableContext.size = image.size
imageView.image = image

let zoomableView = imageView.wrapperToZoomableView()

// 配置缩放
zoomableView.minimumZoomScale = 1.0
zoomableView.maximumZoomScale = 5.0
```

### 图片查看器示例

```swift
final class ImageContentView: UIImageView, SKZoomableContentView {
    let zoomableContext = SKZoomableContext()
}

class ImageViewerController: UIViewController {
    
    private lazy var imageView = ImageContentView()
    
    private lazy var zoomableView: SKZoomableScrollView = {
        imageView.wrapperToZoomableView()
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
        imageView.zoomableContext.size = image.size
        imageView.zoomableContext.singleTapAction = { [weak self] _ in
            self?.toggleChrome()
        }
        
        view.addSubview(zoomableView)
        zoomableView.frame = view.bounds
    }
}
```

## 最佳实践

### 1. 懒加载页面

```swift
// ✅ 推荐 - 延迟创建 ViewController
.init(id: "heavy") { context in
    // 仅在需要时创建
    return HeavyViewController()
}

// ❌ 避免 - 提前创建所有页面
let pages = (0..<10).map { HeavyViewController() }
```

### 2. 页面缓存

```swift
class CachedPageManager {
    private var cache: [String: UIViewController] = [:]
    
    func createPage(id: String) -> SKPageManager.Child {
        .init(id: id) { [weak self] context in
            if let cached = self?.cache[id] {
                return cached
            }
            
            let vc = createViewController(for: id)
            self?.cache[id] = vc
            return vc
        }
    }
}
```

### 3. 内存管理

```swift
pageManager.$current
    .sink { [weak self] page in
        // 清理不可见页面的资源
        self?.cleanupOffscreenPages()
    }
    .store(in: &cancellables)
```

### 4. 状态同步

```swift
// 使用 Combine 保持状态同步
class ViewModel {
    @Published var selectedTab: Int = 0
}

// ViewController
viewModel.$selectedTab
    .assign(to: \.selection, on: pageManager)
    .store(in: &cancellables)

pageManager.$current
    .compactMap { $0?.index }
    .assign(to: \.selectedTab, on: viewModel)
    .store(in: &cancellables)
```
