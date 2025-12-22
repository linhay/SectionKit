---
description: 一个基于 UIPageViewController 的强大页面管理组件，提供了声明式 API 和响应式数据绑定能力。
---

# SKPageViewController


一个基于 `UIPageViewController` 的强大页面管理组件，提供了声明式 API 和响应式数据绑定能力。

## 特性

- ✅ **声明式 API**：链式调用，代码简洁
- ✅ **响应式绑定**：基于 Combine，自动同步状态
- ✅ **延时绑定**：配置阶段不触发 UI 更新，性能优化
- ✅ **智能缓存**：基于 ID 的控制器缓存机制
- ✅ **双向同步**：支持用户手势和程序化切换
- ✅ **灵活配置**：支持水平/垂直滚动、自定义间距

## 基础使用

### 1. 快速开始

```swift
import UIKit

class MyViewController: UIViewController {
    let pageVC = SKPageViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 配置页面
        pageVC.manager.setChilds([
            .init(id: "page1", maker: { _ in Page1ViewController() }),
            .init(id: "page2", maker: { _ in Page2ViewController() }),
            .init(id: "page3", maker: { _ in Page3ViewController() })
        ])
        
        // 添加到视图层级
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        pageVC.view.frame = view.bounds
    }
}
```

### 2. 使用独立的 Manager（推荐）

```swift
class MyViewController: UIViewController {
    let manager = SKPageManager()
    lazy var pageVC: SKPageViewController = {
        let vc = SKPageViewController()
        vc.set(manager: manager)
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 批量配置（不触发 UI 更新）
        manager.configure { m in
            m.setChilds([
                .init(id: "home", maker: { _ in HomeViewController() }),
                .init(id: "profile", maker: { _ in ProfileViewController() })
            ])
            m.selection = 0
            m.spacing = 10
            m.scrollDirection = .horizontal
        }
        
        setupUI()
    }
}
```

## 核心 API

### SKPageManager

#### 属性

```swift
// 只读，通过方法修改
@SKPublished public private(set) var childs: [Child]

// 当前选中的页面索引
@SKPublished public var selection: Int

// 当前页面的完整上下文（包含 id、index、controller）
@Published public var current: ChildContext?

// 滚动方向
@SKPublished public var scrollDirection: UICollectionView.ScrollDirection

// 页面间距
@SKPublished public var spacing: CGFloat

// 是否已绑定到 UI
public private(set) var isBound: Bool
```

#### 页面管理方法

```swift
// 设置所有页面
func setChilds(_ childs: [Child]) -> Self

// 添加单个页面
func addChild(_ child: Child) -> Self

// 添加多个页面
func addChilds(_ childs: [Child]) -> Self

// 移除指定 ID 的页面
func removeChild(id: String) -> Self

// 移除指定索引的页面
func removeChild(at index: Int) -> Self

// 清空所有页面
func removeAllChilds() -> Self

// 替换指定位置的页面
func replaceChild(at index: Int, with child: Child) -> Self

// 插入页面到指定位置
func insertChild(_ child: Child, at index: Int) -> Self
```

#### 工具方法

```swift
// 批量配置
func configure(_ block: (SKPageManager) -> Void) -> Self

// 清理缓存的控制器
func clearCache()

// 解除 UI 绑定，清理所有订阅和缓存
func unbind()
```

### Child 初始化

#### 使用 UIViewController

```swift
.init(id: "unique_id", maker: { context in
    let vc = MyViewController()
    // 可以访问 context.id, context.index, context.controller
    return vc
})
```

#### 使用 UIView（自动包装）

```swift
.init(id: "view_page", maker: { context in
    let view = MyCustomView()
    view.backgroundColor = .white
    return view  // 自动包装成 UIViewController
})
```

#### 使用静态方法

```swift
.withController(id: "page_id") { context in
    MyViewController()
}
```

## 进阶用法

### 监听页面变化

```swift
import Combine

class MyViewController: UIViewController {
    let manager = SKPageManager()
    var cancellables = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 监听当前页面变化
        manager.$current
            .compactMap { $0 }
            .sink { context in
                print("切换到页面: \(context.id) at index \(context.index)")
                // 可以访问 context.controller
            }
            .store(in: &cancellables)
        
        // 监听选中索引变化
        manager.$selection
            .sink { index in
                print("当前索引: \(index)")
                // 更新 UI，如 TabBar、SegmentedControl 等
            }
            .store(in: &cancellables)
    }
}
```

### 动态管理页面

```swift
// 添加新页面
manager.addChild(.init(id: "new_page", maker: { _ in
    NewPageViewController()
}))

// 链式添加
manager
    .addChild(.init(id: "page1", maker: { _ in Page1VC() }))
    .addChild(.init(id: "page2", maker: { _ in Page2VC() }))
    .addChild(.init(id: "page3", maker: { _ in Page3VC() }))

// 移除页面
manager.removeChild(id: "old_page")
manager.removeChild(at: 2)

// 替换页面
manager.replaceChild(at: 1, with: .init(id: "updated", maker: { _ in
    UpdatedViewController()
}))

// 插入页面
manager.insertChild(.init(id: "inserted", maker: { _ in
    InsertedViewController()
}), at: 1)
```

### 程序化切换页面

```swift
// 直接设置索引
manager.selection = 2

// 通过绑定处理切换完成
manager.$selection.sink { newIndex in
    // 页面切换完成
}.store(in: &cancellables)
```

### 配置滚动方向和间距

```swift
// 水平滚动（默认）
manager.scrollDirection = .horizontal
manager.spacing = 10

// 垂直滚动
manager.scrollDirection = .vertical
manager.spacing = 20
```

### 访问子控制器上下文

```swift
manager.addChild(.init(id: "context_aware", maker: { context in
    let vc = DetailViewController()
    vc.pageId = context.id           // 页面 ID
    vc.pageIndex = context.index     // 页面索引
    // context.controller 是父 UIPageViewController 的弱引用
    return vc
}))
```

## 完整示例

### 带标签栏的页面控制器

```swift
import UIKit
import Combine

class TabPageViewController: UIViewController {
    
    // MARK: - Properties
    
    let manager = SKPageManager()
    lazy var pageVC = SKPageViewController()
    let tabBar = UISegmentedControl(items: ["首页", "消息", "我的"])
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPages()
        bindEvents()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // 添加标签栏
        view.addSubview(tabBar)
        tabBar.selectedSegmentIndex = 0
        tabBar.translatesAutoresizingMaskIntoConstraints = false
        
        // 添加页面控制器
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        pageVC.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tabBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
            tabBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            tabBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            pageVC.view.topAnchor.constraint(equalTo: tabBar.bottomAnchor, constant: 10),
            pageVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupPages() {
        manager.configure { m in
            m.setChilds([
                .init(id: "home", maker: { context in
                    let vc = HomeViewController()
                    vc.view.backgroundColor = .systemBlue
                    return vc
                }),
                .init(id: "messages", maker: { context in
                    let vc = MessagesViewController()
                    vc.view.backgroundColor = .systemGreen
                    return vc
                }),
                .init(id: "profile", maker: { context in
                    let vc = ProfileViewController()
                    vc.view.backgroundColor = .systemOrange
                    return vc
                })
            ])
            m.selection = 0
            m.spacing = 15
        }
        
        pageVC.set(manager: manager)
    }
    
    private func bindEvents() {
        // TabBar 点击 → 切换页面
        tabBar.addTarget(self, action: #selector(tabBarChanged), for: .valueChanged)
        
        // 页面滑动 → 更新 TabBar
        manager.$selection
            .sink { [weak self] index in
                self?.tabBar.selectedSegmentIndex = index
            }
            .store(in: &cancellables)
        
        // 监听当前页面
        manager.$current
            .compactMap { $0 }
            .sink { context in
                print("当前页面: \(context.id)")
            }
            .store(in: &cancellables)
    }
    
    @objc private func tabBarChanged() {
        manager.selection = tabBar.selectedSegmentIndex
    }
}
```

### 动态添加/移除页面

```swift
class DynamicPageViewController: UIViewController {
    let manager = SKPageManager()
    lazy var pageVC = SKPageViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 初始页面
        manager.configure { m in
            m.addChild(.init(id: "page1", maker: { _ in Page1VC() }))
            m.addChild(.init(id: "page2", maker: { _ in Page2VC() }))
        }
        
        pageVC.set(manager: manager)
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        
        // 添加按钮
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPage))
        let removeButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(removePage))
        navigationItem.rightBarButtonItems = [addButton, removeButton]
    }
    
    @objc func addPage() {
        let newId = "page_\(UUID().uuidString.prefix(8))"
        manager.addChild(.init(id: newId, maker: { context in
            let vc = UIViewController()
            vc.view.backgroundColor = .random()
            return vc
        }))
    }
    
    @objc func removePage() {
        guard manager.childs.count > 1 else { return }
        manager.removeChild(at: manager.childs.count - 1)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1),
            alpha: 1.0
        )
    }
}
```

## 性能优化

### 延时绑定

在配置大量页面时，使用 `configure` 块避免多次触发 UI 更新：

```swift
// ❌ 不推荐：每次设置都触发更新
manager.setChilds([...])
manager.selection = 2
manager.spacing = 10

// ✅ 推荐：批量配置
manager.configure { m in
    m.setChilds([...])
    m.selection = 2
    m.spacing = 10
}
// 只在 makePageController() 调用时才绑定 UI
```

### 缓存管理

控制器会自动缓存，基于 `Child.id` 进行识别：

```swift
// 检查绑定状态
if manager.isBound {
    print("已绑定到 UI")
}

// 清理缓存的控制器（保留页面配置）
manager.clearCache()

// 完全解绑（清理订阅、缓存、容器）
manager.unbind()

// 重新配置后再绑定
manager.configure { m in
    m.setChilds([...])
}
let newPageVC = manager.makePageController()
```

### 懒加载页面

页面控制器是懒加载的，只有在需要显示时才会创建：

```swift
// maker 闭包在页面首次显示时才执行
.init(id: "lazy_page", maker: { context in
    print("页面 \(context.index) 被创建")
    return ExpensiveViewController()
})
```

## 注意事项

1. **ID 唯一性**：每个 `Child` 的 `id` 必须唯一，用于缓存识别
2. **内存管理**：`ChildContext.controller` 是弱引用，避免循环引用
3. **线程安全**：所有 UI 操作必须在主线程执行
4. **缓存策略**：基于 ID 缓存，改变 `childs` 会自动清理失效缓存
5. **状态同步**：`selection` 和 `current` 双向同步，修改任一都会更新另一个

## 常见问题

### Q: 如何获取当前显示的页面控制器？

```swift
if let current = manager.current {
    print("当前页面 ID: \(current.id)")
    print("当前页面索引: \(current.index)")
    if let controller = current.controller {
        print("当前控制器: \(controller)")
    }
}
```

### Q: 如何禁用手势滑动？

`UIPageViewController` 不直接支持禁用手势，但可以通过自定义手势识别器实现：

```swift
if let scrollView = pageVC.pageController.view.subviews.first(where: { $0 is UIScrollView }) as? UIScrollView {
    scrollView.isScrollEnabled = false
}
```

### Q: 如何设置切换动画？

修改 `setViewControllers` 的 `animated` 参数（需要修改源码）。

### Q: 页面数量可以动态改变吗？

可以，使用 `addChild`、`removeChild` 等方法动态管理。

### Q: 如何在页面间传递数据？

```swift
.init(id: "detail", maker: { context in
    let vc = DetailViewController()
    vc.data = myData  // 直接传递
    return vc
})
```

## License

MIT License - 参见项目根目录的 LICENSE 文件。
