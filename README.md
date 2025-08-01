<p align="center">
  <img src="https://raw.githubusercontent.com/linhay/SectionKit/dev/Documentation/Images/icon.svg" width=450 />
</p>

<p align="center">
<a href="https://deepwiki.com/linhay/SectionKit"><img src="https://deepwiki.com/badge.svg" alt="Documentation"></a>
  <a href="https://cocoapods.org/pods/SectionUI"><img src="https://img.shields.io/cocoapods/v/SectionUI.svg?style=flat" alt="Pods Version"></a>
  <a href="https://cocoapods.org/pods/SectionUI"><img src="https://img.shields.io/cocoapods/p/SectionUI.svg?style=flat" alt="Platforms"></a>
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-5.8+-orange.svg" alt="Swift Version"></a>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/License-Apache%202.0-blue.svg" alt="License"></a>
</p>

<p align="center">
  <a href="README.md">🇨🇳 中文</a> |
  <a href="README_EN.md">🇺🇸 English</a> |
  <a href="README_JA.md">🇯🇵 日本語</a>
</p>

---

一个功能强大、数据驱动的 `UICollectionView` 框架，专为构建快速、灵活、高性能的列表而设计。

## ✨ 主要特性

|           | 特性描述                                  |
| --------- | ----------------------------------------- |
| 🏗️ | **架构优秀** - 可复用的 Cell 和组件体系结构 |
| 📱 | **多数据类型** - 轻松创建具有多个数据类型的复杂列表 |
| ⚡ | **高性能** - 高性能的数据处理和视图复用机制 |
| 🔧 | **功能丰富** - 大量插件和扩展帮助构建完美列表 |
| 🦉 | **现代化** - 纯 Swift 编写，完整支持 SwiftUI |
| 🎨 | **布局灵活** - 支持网格、瀑布流等多种布局方式 |

## 🚀 快速开始

### 基础示例

创建一个待办事项列表：

```swift
import SectionUI
import SwiftUI

// 创建待办事项 Cell
class TodoItemCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    struct Model {
        let task: String
        let isCompleted: Bool
        let priority: Priority
        
        enum Priority {
            case high, medium, low
            var color: UIColor {
                switch self {
                case .high: return .systemRed
                case .medium: return .systemOrange
                case .low: return .systemGreen
                }
            }
        }
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return .init(width: size.width, height: 60)
    }
    
    func config(_ model: Model) {
        taskLabel.text = model.task
        priorityView.backgroundColor = model.priority.color
        taskLabel.textColor = model.isCompleted ? .systemGray : .label
        taskLabel.attributedText = model.isCompleted ? 
            NSAttributedString(string: model.task, attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]) :
            NSAttributedString(string: model.task)
    }
    
    // UI 组件配置...
    private lazy var taskLabel = UILabel()
    private lazy var priorityView = UIView()
}

struct TodoListView: View {
    @State var todoSection = TodoItemCell.wrapperToSingleTypeSection()
    
    var body: some View {
        SKPreview.sections { todoSection }
            .task {
                todoSection.config(models: [
                    .init(task: "完成项目提案", isCompleted: false, priority: .high),
                    .init(task: "回复邮件", isCompleted: true, priority: .medium),
                    .init(task: "买菜", isCompleted: false, priority: .low)
                ])
            }
    }
}
```

## 📖 详细示例

### 1. 单一类型列表

创建一个产品展示列表：

```swift
class ProductCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    struct Model {
        let name: String
        let price: Double
        let category: String
        let isOnSale: Bool
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return .init(width: size.width, height: 80)
    }
    
    func config(_ model: Model) {
        nameLabel.text = model.name
        priceLabel.text = String(format: "¥%.2f", model.price)
        categoryLabel.text = model.category
        salesBadge.isHidden = !model.isOnSale
        priceLabel.textColor = model.isOnSale ? .systemRed : .label
    }
    
    // UI 组件实现...
    private lazy var nameLabel = UILabel()
    private lazy var priceLabel = UILabel()
    private lazy var categoryLabel = UILabel()
    private lazy var salesBadge = UIView()
}

// 创建产品列表
let productSection = ProductCell
    .wrapperToSingleTypeSection()
    .onCellAction(.selected) { context in
        showProductDetail(context.model)
    }
    .onCellAction(.willDisplay) { context in
        // 预加载产品图片
        loadProductImage(for: context.model)
    }

productSection.config(models: [
    .init(name: "iPhone 15 Pro", price: 7999.0, category: "手机", isOnSale: false),
    .init(name: "MacBook Air", price: 8999.0, category: "电脑", isOnSale: true)
])
```

### 2. 多组列表

创建新闻应用的分类展示：

```swift
// 新闻标题 Cell
class NewsHeaderCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    struct Model {
        let categoryName: String
        let newsCount: Int
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        .init(width: size.width, height: 50)
    }
    
    func config(_ model: Model) {
        titleLabel.text = model.categoryName
        countLabel.text = "\(model.newsCount) 条新闻"
    }
}

// 新闻条目 Cell
class NewsItemCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    struct Model {
        let headline: String
        let source: String
        let publishTime: Date
        let readCount: Int
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        .init(width: size.width, height: 100)
    }
    
    func config(_ model: Model) {
        headlineLabel.text = model.headline
        sourceLabel.text = model.source
        timeLabel.text = DateFormatter.newsTime.string(from: model.publishTime)
        readCountLabel.text = "\(model.readCount) 次阅读"
    }
}

struct NewsView: View {
    @State var headlineSection = NewsHeaderCell.wrapperToSingleTypeSection()
    @State var technologySection = NewsItemCell.wrapperToSingleTypeSection()
    @State var sportsSection = NewsItemCell.wrapperToSingleTypeSection()
    
    var body: some View {
        SKPreview.sections {
            headlineSection
            technologySection
            sportsSection
        }
        .task {
            // 配置头条区域
            headlineSection.config(models: [
                .init(categoryName: "今日头条", newsCount: 15)
            ])
            
            // 配置科技新闻
            technologySection.config(models: [
                .init(headline: "苹果发布新款芯片", source: "科技日报", publishTime: Date(), readCount: 1250),
                .init(headline: "AI 技术新突破", source: "技术周刊", publishTime: Date(), readCount: 980)
            ])
            
            // 配置体育新闻
            sportsSection.config(models: [
                .init(headline: "世界杯决赛精彩回顾", source: "体育报", publishTime: Date(), readCount: 2100)
            ])
        }
    }
}
```

### 3. Header 和 Footer

为电商商品列表添加分类标题和统计信息：

```swift
// 分类标题视图
class CategoryHeaderView: UICollectionReusableView, SKLoadViewProtocol, SKConfigurableView {
    struct Model {
        let categoryName: String
        let brandCount: Int
        let discountInfo: String?
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        .init(width: size.width, height: 60)
    }
    
    func config(_ model: Model) {
        categoryLabel.text = model.categoryName
        brandCountLabel.text = "\(model.brandCount) 个品牌"
        discountLabel.text = model.discountInfo
        discountLabel.isHidden = model.discountInfo == nil
    }
}

// 统计信息 Footer
class CategoryFooterView: UICollectionReusableView, SKLoadViewProtocol, SKConfigurableView {
    struct Model {
        let totalProducts: Int
        let averagePrice: Double
        let topBrand: String
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        .init(width: size.width, height: 40)
    }
    
    func config(_ model: Model) {
        statsLabel.text = "共 \(model.totalProducts) 件商品 · 均价 ¥\(String(format: "%.0f", model.averagePrice)) · 热门品牌: \(model.topBrand)"
    }
}

// 商品 Cell
class ProductItemCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    struct Model {
        let productName: String
        let brand: String
        let currentPrice: Double
        let originalPrice: Double?
        let rating: Double
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        .init(width: size.width, height: 120)
    }
    
    func config(_ model: Model) {
        nameLabel.text = model.productName
        brandLabel.text = model.brand
        priceLabel.text = String(format: "¥%.2f", model.currentPrice)
        
        if let originalPrice = model.originalPrice {
            originalPriceLabel.text = String(format: "¥%.2f", originalPrice)
            originalPriceLabel.isHidden = false
        } else {
            originalPriceLabel.isHidden = true
        }
        
        ratingLabel.text = String(format: "%.1f⭐", model.rating)
    }
}

// 使用示例
let electronicsSection = ProductItemCell
    .wrapperToSingleTypeSection()
    .setSectionStyle { section in
        section.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        section.minimumLineSpacing = 8
    }
    .setHeader(CategoryHeaderView.self, 
               model: .init(categoryName: "数码产品", brandCount: 25, discountInfo: "限时8折优惠"))
    .setFooter(CategoryFooterView.self,
               model: .init(totalProducts: 156, averagePrice: 2599.0, topBrand: "Apple"))

electronicsSection.config(models: [
    .init(productName: "无线蓝牙耳机", brand: "Sony", currentPrice: 899.0, originalPrice: 1299.0, rating: 4.8),
    .init(productName: "机械键盘", brand: "罗技", currentPrice: 599.0, originalPrice: nil, rating: 4.6)
])
```

### 4. 数据加载和刷新

实现社交媒体的动态加载：

```swift
// 动态 Cell
class SocialPostCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    struct Model {
        let authorName: String
        let authorAvatar: String
        let content: String
        let likeCount: Int
        let commentCount: Int
        let publishTime: Date
        let isLiked: Bool
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        // 根据内容动态计算高度
        guard let model = model else { return .init(width: size.width, height: 150) }
        let contentHeight = model.content.boundingRect(
            with: CGSize(width: size.width - 32, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin],
            attributes: [.font: UIFont.systemFont(ofSize: 16)],
            context: nil
        ).height
        return .init(width: size.width, height: contentHeight + 100) // 100 是固定的 UI 部分高度
    }
    
    func config(_ model: Model) {
        authorLabel.text = model.authorName
        contentLabel.text = model.content
        likeButton.setTitle("\(model.likeCount)", for: .normal)
        commentButton.setTitle("\(model.commentCount)", for: .normal)
        timeLabel.text = RelativeDateTimeFormatter().localizedString(for: model.publishTime, relativeTo: Date())
        likeButton.isSelected = model.isLiked
    }
}

struct SocialFeedView: View {
    @State var postsSection = SocialPostCell.wrapperToSingleTypeSection()
    @State var currentPage = 0
    @State var isLoading = false
    
    var body: some View {
        SKUIController {
            let controller = SKCollectionViewController()
            controller.reloadSections(postsSection)
            
            // 下拉刷新配置
            controller.refreshable {
                await refreshLatestPosts()
            }
            
            // 监听滚动到底部，实现无限加载
            controller.manager.scrollObserver.add { handle in
                handle.onChanged { scrollView in
                    let offsetY = scrollView.contentOffset.y
                    let contentHeight = scrollView.contentSize.height
                    let frameHeight = scrollView.frame.height
                    
                    if offsetY > contentHeight - frameHeight - 100 && !isLoading {
                        Task { await loadMorePosts() }
                    }
                }
            }
            
            return controller
        }
    }
    
    private func refreshLatestPosts() async {
        isLoading = true
        currentPage = 0
        
        // 模拟网络请求
        let newPosts = await fetchPosts(page: currentPage)
        
        await MainActor.run {
            postsSection.config(models: newPosts)
            isLoading = false
        }
    }
    
    private func loadMorePosts() async {
        isLoading = true
        currentPage += 1
        
        let morePosts = await fetchPosts(page: currentPage)
        
        await MainActor.run {
            postsSection.append(morePosts)
            isLoading = false
        }
    }
    
    private func fetchPosts(page: Int) async -> [SocialPostCell.Model] {
        // 模拟异步数据获取
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        return (0..<10).map { index in
            SocialPostCell.Model(
                authorName: "用户\(page * 10 + index)",
                authorAvatar: "avatar_\(index)",
                content: "这是一条示例动态内容，展示社交媒体的文字信息。用户可以在这里分享生活、工作或其他有趣的内容。",
                likeCount: Int.random(in: 5...999),
                commentCount: Int.random(in: 0...50),
                publishTime: Date().addingTimeInterval(-Double.random(in: 0...86400)),
                isLiked: Bool.random()
            )
        }
    }
}
```

### 5. Combine 数据绑定

创建股票价格实时更新列表：

```swift
// 股票数据模型
struct StockData {
    let symbol: String
    let companyName: String
    let currentPrice: Double
    let changeAmount: Double
    let changePercent: Double
    let volume: Int
    let marketCap: String
    
    var isGaining: Bool { changeAmount > 0 }
}

// 股票 Cell
class StockTickerCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    typealias Model = StockData
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        .init(width: size.width, height: 80)
    }
    
    func config(_ model: Model) {
        symbolLabel.text = model.symbol
        companyLabel.text = model.companyName
        priceLabel.text = String(format: "$%.2f", model.currentPrice)
        
        let changeText = String(format: "%.2f (%.2f%%)", 
                               model.changeAmount, model.changePercent)
        changeLabel.text = model.isGaining ? "+\(changeText)" : changeText
        changeLabel.textColor = model.isGaining ? .systemGreen : .systemRed
        
        priceLabel.textColor = model.isGaining ? .systemGreen : .systemRed
        volumeLabel.text = "成交量: \(formatVolume(model.volume))"
        marketCapLabel.text = "市值: \(model.marketCap)"
    }
    
    private func formatVolume(_ volume: Int) -> String {
        if volume >= 1_000_000 {
            return String(format: "%.1fM", Double(volume) / 1_000_000)
        } else if volume >= 1_000 {
            return String(format: "%.1fK", Double(volume) / 1_000)
        } else {
            return "\(volume)"
        }
    }
}

// 股票市场数据管理器
class StockMarketDataManager: ObservableObject {
    @Published var stocks: [StockData] = []
    private var updateTimer: Timer?
    
    func startRealTimeUpdates() {
        // 初始化股票数据
        stocks = createInitialStocks()
        
        // 每2秒更新一次价格
        updateTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            self.updateStockPrices()
        }
    }
    
    func stopUpdates() {
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    private func updateStockPrices() {
        stocks = stocks.map { stock in
            let priceChange = Double.random(in: -0.50...0.50)
            let newPrice = max(0.01, stock.currentPrice + priceChange)
            let changePercent = (priceChange / stock.currentPrice) * 100
            
            return StockData(
                symbol: stock.symbol,
                companyName: stock.companyName,
                currentPrice: newPrice,
                changeAmount: priceChange,
                changePercent: changePercent,
                volume: stock.volume + Int.random(in: -1000...1000),
                marketCap: stock.marketCap
            )
        }
    }
    
    private func createInitialStocks() -> [StockData] {
        return [
            StockData(symbol: "AAPL", companyName: "苹果公司", currentPrice: 175.50, 
                     changeAmount: 2.30, changePercent: 1.33, volume: 50_234_000, marketCap: "2.75T"),
            StockData(symbol: "GOOGL", companyName: "谷歌", currentPrice: 2650.80, 
                     changeAmount: -15.20, changePercent: -0.57, volume: 1_234_000, marketCap: "1.69T"),
            StockData(symbol: "MSFT", companyName: "微软", currentPrice: 378.90, 
                     changeAmount: 5.60, changePercent: 1.50, volume: 28_456_000, marketCap: "2.81T")
        ]
    }
}

struct StockMarketView: View {
    @StateObject private var dataManager = StockMarketDataManager()
    @State private var stockSection = StockTickerCell.wrapperToSingleTypeSection()
    
    var body: some View {
        SKPreview.sections { stockSection }
            .onReceive(dataManager.$stocks) { updatedStocks in
                // 使用差异化更新，避免不必要的 UI 刷新
                stockSection.config(models: updatedStocks, kind: .difference { lhs, rhs in
                    lhs.symbol == rhs.symbol && 
                    abs(lhs.currentPrice - rhs.currentPrice) < 0.01
                })
            }
            .onAppear {
                dataManager.startRealTimeUpdates()
            }
            .onDisappear {
                dataManager.stopUpdates()
            }
            .navigationTitle("股票市场")
    }
}
```

### 6. 网格布局

创建照片墙应用：

```swift
// 照片 Cell
class PhotoGridCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    struct Model {
        let imageURL: String
        let photographer: String
        let location: String
        let likes: Int
        let uploadDate: Date
        let tags: [String]
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        // 网格布局，让 section 控制具体尺寸
        return size
    }
    
    func config(_ model: Model) {
        // 加载图片（这里用颜色代替）
        imageView.backgroundColor = UIColor.random()
        photographerLabel.text = model.photographer
        locationLabel.text = model.location
        likesLabel.text = "❤️ \(model.likes)"
        
        // 配置标签
        tagsLabel.text = model.tags.prefix(2).joined(separator: " ")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        imageView.backgroundColor = .systemGray5
    }
}

// 照片墙视图
struct PhotoWallView: View {
    @State private var photoSection = PhotoGridCell
        .wrapperToSingleTypeSection()
        .setSectionStyle { section in
            section.minimumLineSpacing = 4
            section.minimumInteritemSpacing = 4
            section.sectionInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }
        // 使用安全尺寸控制网格布局：每行3列，宽高比1:1
        .cellSafeSize(.fraction(1.0/3.0), transforms: .height(asRatioOfWidth: 1.0))
        .onCellAction(.selected) { context in
            showPhotoDetail(context.model)
        }
    
    var body: some View {
        SKPreview.sections { photoSection }
            .task {
                photoSection.config(models: generatePhotoData())
            }
            .navigationTitle("照片墙")
            .navigationBarTitleDisplayMode(.large)
    }
    
    private func generatePhotoData() -> [PhotoGridCell.Model] {
        let photographers = ["Alice Chen", "Bob Smith", "Carol Wang", "David Lee"]
        let locations = ["纽约", "巴黎", "东京", "伦敦", "悉尼", "北京"]
        let tags = [["自然", "风景"], ["建筑", "城市"], ["人物", "肖像"], ["美食", "生活"], ["动物", "可爱"]]
        
        return (0..<50).map { index in
            PhotoGridCell.Model(
                imageURL: "https://example.com/photo\(index).jpg",
                photographer: photographers[index % photographers.count],
                location: locations[index % locations.count],
                likes: Int.random(in: 10...999),
                uploadDate: Date().addingTimeInterval(-Double.random(in: 0...2592000)), // 最近30天
                tags: tags[index % tags.count]
            )
        }
    }
    
    private func showPhotoDetail(_ model: PhotoGridCell.Model) {
        // 显示照片详情页面
        print("显示照片详情: \(model.photographer) 的作品")
    }
}

// 扩展 UIColor 生成随机颜色
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

### 7. 装饰视图

创建日历应用的月份背景装饰：

```swift
// 日期 Cell
class CalendarDayCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    struct Model {
        let day: Int
        let isCurrentMonth: Bool
        let isToday: Bool
        let hasEvents: Bool
        let eventCount: Int
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        let cellSize = min(size.width / 7, 60) // 7天一周
        return .init(width: cellSize, height: cellSize)
    }
    
    func config(_ model: Model) {
        dayLabel.text = "\(model.day)"
        dayLabel.textColor = model.isCurrentMonth ? .label : .secondaryLabel
        
        // 今天的特殊样式
        if model.isToday {
            backgroundColor = .systemBlue
            dayLabel.textColor = .white
            layer.cornerRadius = bounds.width / 2
        } else {
            backgroundColor = .clear
            layer.cornerRadius = 0
        }
        
        // 显示事件指示器
        eventIndicator.isHidden = !model.hasEvents
        if model.hasEvents {
            eventCountLabel.text = "\(model.eventCount)"
            eventIndicator.backgroundColor = model.isToday ? .white : .systemRed
        }
    }
}

// 月份背景装饰视图
class MonthBackgroundDecorationView: UICollectionReusableView {
    private let monthLabel = UILabel()
    private let backgroundView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        // 背景设置
        backgroundView.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.8)
        backgroundView.layer.cornerRadius = 16
        backgroundView.layer.shadowColor = UIColor.black.cgColor
        backgroundView.layer.shadowOffset = CGSize(width: 0, height: 2)
        backgroundView.layer.shadowOpacity = 0.1
        backgroundView.layer.shadowRadius = 8
        
        // 月份标签
        monthLabel.font = UIFont.systemFont(ofSize: 48, weight: .bold)
        monthLabel.textColor = .systemBlue.withAlphaComponent(0.2)
        monthLabel.textAlignment = .center
        
        addSubview(backgroundView)
        addSubview(monthLabel)
        
        // 布局
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        monthLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            
            monthLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            monthLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    func configure(monthName: String) {
        monthLabel.text = monthName
    }
}

struct CalendarView: View {
    @State private var calendarSection = CalendarDayCell
        .wrapperToSingleTypeSection()
        .setSectionStyle { section in
            section.minimumLineSpacing = 2
            section.minimumInteritemSpacing = 2
            section.sectionInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        }
        .cellSafeSize(.fraction(1.0/7.0), transforms: .height(asRatioOfWidth: 1.0))
        .decorationView(MonthBackgroundDecorationView.self) { context in
            if let decorationView = context.view() as? MonthBackgroundDecorationView {
                decorationView.configure(monthName: getCurrentMonthName())
            }
        }
    
    var body: some View {
        SKPreview.sections { calendarSection }
            .task {
                calendarSection.config(models: generateCalendarData())
            }
            .navigationTitle("日历")
    }
    
    private func generateCalendarData() -> [CalendarDayCell.Model] {
        let calendar = Calendar.current
        let today = Date()
        let currentMonth = calendar.component(.month, from: today)
        let currentDay = calendar.component(.day, from: today)
        
        return (1...31).map { day in
            CalendarDayCell.Model(
                day: day,
                isCurrentMonth: true,
                isToday: day == currentDay,
                hasEvents: Bool.random(),
                eventCount: Int.random(in: 1...3)
            )
        }
    }
    
    private func getCurrentMonthName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: Date())
    }
}
```

### 8. 索引标题

创建企业通讯录的字母索引：

```swift
// 员工联系人 Cell
class EmployeeContactCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    struct Model {
        let employeeId: String
        let name: String
        let department: String
        let position: String
        let phone: String
        let email: String
        let avatarURL: String?
        let isOnline: Bool
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        .init(width: size.width, height: 70)
    }
    
    func config(_ model: Model) {
        nameLabel.text = model.name
        departmentLabel.text = model.department
        positionLabel.text = model.position
        phoneLabel.text = model.phone
        
        // 在线状态指示器
        onlineIndicator.backgroundColor = model.isOnline ? .systemGreen : .systemGray
        onlineIndicator.isHidden = false
        
        // 头像设置（这里用首字母代替）
        avatarLabel.text = String(model.name.prefix(1))
        avatarView.backgroundColor = generateAvatarColor(from: model.name)
    }
    
    private func generateAvatarColor(from name: String) -> UIColor {
        let colors: [UIColor] = [.systemBlue, .systemGreen, .systemOrange, .systemPurple, .systemRed]
        let hash = abs(name.hash)
        return colors[hash % colors.count]
    }
}

// 部门分组数据结构
struct DepartmentGroup {
    let departmentName: String
    let indexTitle: String
    let employees: [EmployeeContactCell.Model]
}

struct CorporateDirectoryView: View {
    @State private var departmentSections: [SKCSingleTypeSection<EmployeeContactCell>] = []
    
    var body: some View {
        SKPreview.sections { departmentSections }
            .task {
                setupDepartmentSections()
            }
            .navigationTitle("企业通讯录")
    }
    
    private func setupDepartmentSections() {
        let departments = createDepartmentData()
        
        departmentSections = departments.map { department in
            EmployeeContactCell
                .wrapperToSingleTypeSection(department.employees)
                .setSectionStyle { section in
                    section.indexTitle = department.indexTitle
                    section.sectionInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
                    section.minimumLineSpacing = 4
                }
                .setHeader(DepartmentHeaderView.self, 
                          model: .init(departmentName: department.departmentName, 
                                      employeeCount: department.employees.count))
                .onCellAction(.selected) { context in
                    showEmployeeDetail(context.model)
                }
        }
    }
    
    private func createDepartmentData() -> [DepartmentGroup] {
        return [
            DepartmentGroup(
                departmentName: "技术部",
                indexTitle: "T",
                employees: [
                    .init(employeeId: "T001", name: "张三", department: "技术部", position: "高级工程师", 
                          phone: "13800138001", email: "zhangsan@company.com", avatarURL: nil, isOnline: true),
                    .init(employeeId: "T002", name: "李四", department: "技术部", position: "架构师", 
                          phone: "13800138002", email: "lisi@company.com", avatarURL: nil, isOnline: false)
                ]
            ),
            DepartmentGroup(
                departmentName: "市场部",
                indexTitle: "M",
                employees: [
                    .init(employeeId: "M001", name: "王五", department: "市场部", position: "市场经理", 
                          phone: "13800138003", email: "wangwu@company.com", avatarURL: nil, isOnline: true),
                    .init(employeeId: "M002", name: "赵六", department: "市场部", position: "销售主管", 
                          phone: "13800138004", email: "zhaoliu@company.com", avatarURL: nil, isOnline: true)
                ]
            ),
            DepartmentGroup(
                departmentName: "人事部",
                indexTitle: "H",
                employees: [
                    .init(employeeId: "H001", name: "孙七", department: "人事部", position: "HR经理", 
                          phone: "13800138005", email: "sunqi@company.com", avatarURL: nil, isOnline: false)
                ]
            ),
            DepartmentGroup(
                departmentName: "财务部",
                indexTitle: "F",
                employees: [
                    .init(employeeId: "F001", name: "周八", department: "财务部", position: "财务总监", 
                          phone: "13800138006", email: "zhouba@company.com", avatarURL: nil, isOnline: true),
                    .init(employeeId: "F002", name: "吴九", department: "财务部", position: "会计师", 
                          phone: "13800138007", email: "wujiu@company.com", avatarURL: nil, isOnline: false)
                ]
            )
        ]
    }
    
    private func showEmployeeDetail(_ employee: EmployeeContactCell.Model) {
        print("显示员工详情: \(employee.name) - \(employee.position)")
    }
}

// 部门标题视图
class DepartmentHeaderView: UICollectionReusableView, SKLoadViewProtocol, SKConfigurableView {
    struct Model {
        let departmentName: String
        let employeeCount: Int
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        .init(width: size.width, height: 40)
    }
    
    func config(_ model: Model) {
        departmentLabel.text = model.departmentName
        employeeCountLabel.text = "\(model.employeeCount) 人"
    }
}
```

### 9. 分页视图

创建产品展示的轮播效果：

```swift
// 产品展示 Cell
class ProductShowcaseCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    struct Model {
        let productName: String
        let category: String
        let price: Double
        let originalPrice: Double?
        let imageURL: String
        let features: [String]
        let rating: Double
        let reviewCount: Int
        let isNewArrival: Bool
        let discount: Double?
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        // 全屏尺寸，用于分页展示
        return size
    }
    
    func config(_ model: Model) {
        productNameLabel.text = model.productName
        categoryLabel.text = model.category
        priceLabel.text = String(format: "¥%.2f", model.price)
        
        // 原价和折扣显示
        if let originalPrice = model.originalPrice {
            originalPriceLabel.text = String(format: "¥%.2f", originalPrice)
            originalPriceLabel.isHidden = false
            
            if let discount = model.discount {
                discountLabel.text = String(format: "%.0f%% OFF", discount * 100)
                discountLabel.isHidden = false
            }
        } else {
            originalPriceLabel.isHidden = true
            discountLabel.isHidden = true
        }
        
        // 特性标签
        featuresLabel.text = model.features.joined(separator: " · ")
        
        // 评分和评论
        ratingLabel.text = String(format: "%.1f", model.rating)
        reviewCountLabel.text = "(\(model.reviewCount) 条评价)"
        
        // 新品标识
        newArrivalBadge.isHidden = !model.isNewArrival
        
        // 背景颜色（模拟产品图片）
        backgroundImageView.backgroundColor = generateProductColor(from: model.productName)
    }
    
    private func generateProductColor(from name: String) -> UIColor {
        let colors: [UIColor] = [
            .systemBlue, .systemPurple, .systemGreen, 
            .systemOrange, .systemRed, .systemTeal
        ]
        let hash = abs(name.hash)
        return colors[hash % colors.count].withAlphaComponent(0.3)
    }
}

struct ProductShowcaseView: View {
    @State private var currentPage: Int = 0
    @State private var productSection = ProductShowcaseCell.wrapperToSingleTypeSection()
    @State private var products: [ProductShowcaseCell.Model] = []
    
    var body: some View {
        SKUIController {
            let controller = SKCollectionViewController()
            controller.reloadSections(productSection)
            
            // 配置分页滚动
            controller.sectionView.isPagingEnabled = true
            controller.sectionView.bounces = false
            controller.sectionView.showsVerticalScrollIndicator = false
            
            // 监听分页变化
            controller.manager.scrollObserver.add { handle in
                handle.onChanged { scrollView in
                    let pageHeight = scrollView.bounds.height
                    let offsetY = scrollView.contentOffset.y
                    let newPage = Int(round(offsetY / pageHeight))
                    
                    if newPage != currentPage && newPage >= 0 && newPage < products.count {
                        currentPage = newPage
                    }
                }
            }
            
            return controller
        }
        .overlay(alignment: .topTrailing) {
            // 页面指示器
            PageIndicatorView(currentPage: currentPage, totalPages: products.count)
                .padding()
        }
        .overlay(alignment: .bottom) {
            // 底部操作栏
            ProductActionBar(
                currentProduct: currentPage < products.count ? products[currentPage] : nil,
                onAddToCart: { addToCart(products[currentPage]) },
                onBuyNow: { buyNow(products[currentPage]) }
            )
        }
        .task {
            setupProducts()
        }
        .animation(.easeInOut(duration: 0.3), value: currentPage)
    }
    
    private func setupProducts() {
        products = createSampleProducts()
        productSection.config(models: products)
    }
    
    private func createSampleProducts() -> [ProductShowcaseCell.Model] {
        return [
            .init(
                productName: "iPhone 15 Pro Max",
                category: "智能手机",
                price: 9999.0,
                originalPrice: 10999.0,
                imageURL: "iphone15pro.jpg",
                features: ["A17 Pro芯片", "钛金属边框", "120Hz显示屏"],
                rating: 4.8,
                reviewCount: 1234,
                isNewArrival: true,
                discount: 0.09
            ),
            .init(
                productName: "MacBook Air M3",
                category: "笔记本电脑",
                price: 8999.0,
                originalPrice: nil,
                imageURL: "macbook_air_m3.jpg",
                features: ["M3芯片", "15英寸显示屏", "18小时续航"],
                rating: 4.9,
                reviewCount: 856,
                isNewArrival: false,
                discount: nil
            ),
            .init(
                productName: "AirPods Pro 3",
                category: "音频设备",
                price: 1899.0,
                originalPrice: 2199.0,
                imageURL: "airpods_pro_3.jpg",
                features: ["主动降噪", "空间音频", "无线充电"],
                rating: 4.7,
                reviewCount: 2341,
                isNewArrival: true,
                discount: 0.14
            )
        ]
    }
    
    private func addToCart(_ product: ProductShowcaseCell.Model) {
        print("添加到购物车: \(product.productName)")
    }
    
    private func buyNow(_ product: ProductShowcaseCell.Model) {
        print("立即购买: \(product.productName)")
    }
}

// 页面指示器组件
struct PageIndicatorView: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? Color.primary : Color.secondary)
                    .frame(width: 8, height: 8)
                    .scaleEffect(index == currentPage ? 1.2 : 1.0)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
    }
}

// 产品操作栏组件
struct ProductActionBar: View {
    let currentProduct: ProductShowcaseCell.Model?
    let onAddToCart: () -> Void
    let onBuyNow: () -> Void
    
    var body: some View {
        if let product = currentProduct {
            HStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.productName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    HStack {
                        Text(String(format: "¥%.2f", product.price))
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        if let originalPrice = product.originalPrice {
                            Text(String(format: "¥%.2f", originalPrice))
                                .font(.caption)
                                .strikethrough()
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                Button("加入购物车", action: onAddToCart)
                    .buttonStyle(.bordered)
                
                Button("立即购买", action: onBuyNow)
                    .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.thinMaterial)
        }
    }
}
```

### 10. 选择管理

创建购物车的多选功能：

```swift
// 购物车商品数据模型
struct CartItem {
    let id: String
    let productName: String
    let brand: String
    let price: Double
    let originalPrice: Double?
    let imageURL: String
    let quantity: Int
    let isAvailable: Bool
    let shippingInfo: String
}

// 可选择的购物车商品 Cell
class SelectableCartItemCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    typealias Model = SKSelectionWrapper<CartItem>
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        .init(width: size.width, height: 120)
    }
    
    func config(_ model: Model) {
        let item = model.element
        
        // 商品信息
        productNameLabel.text = item.productName
        brandLabel.text = item.brand
        priceLabel.text = String(format: "¥%.2f", item.price)
        quantityLabel.text = "数量: \(item.quantity)"
        shippingLabel.text = item.shippingInfo
        
        // 原价显示
        if let originalPrice = item.originalPrice {
            originalPriceLabel.text = String(format: "¥%.2f", originalPrice)
            originalPriceLabel.isHidden = false
        } else {
            originalPriceLabel.isHidden = true
        }
        
        // 选择状态
        selectionCheckbox.isSelected = model.isSelected
        
        // 可用性状态
        contentView.alpha = item.isAvailable ? 1.0 : 0.6
        unavailableLabel.isHidden = item.isAvailable
        
        // 选择框颜色
        selectionCheckbox.tintColor = model.isSelected ? .systemBlue : .systemGray3
        
        // 背景色变化
        backgroundColor = model.isSelected ? 
            UIColor.systemBlue.withAlphaComponent(0.1) : .systemBackground
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = .systemBackground
        contentView.alpha = 1.0
    }
    
    // UI 组件定义...
    private lazy var selectionCheckbox = UIButton()
    private lazy var productImageView = UIImageView()
    private lazy var productNameLabel = UILabel()
    private lazy var brandLabel = UILabel()
    private lazy var priceLabel = UILabel() 
    private lazy var originalPriceLabel = UILabel()
    private lazy var quantityLabel = UILabel()
    private lazy var shippingLabel = UILabel()
    private lazy var unavailableLabel = UILabel()
}

struct ShoppingCartView: View {
    @State private var cartSection = SelectableCartItemCell.wrapperToSingleTypeSection()
    @State private var cartItems: [CartItem] = []
    @State private var selectionManager = SKSelectionManager<CartItem>()
    
    var body: some View {
        VStack(spacing: 0) {
            // 列表内容
            SKPreview.sections { cartSection }
            
            // 底部操作栏
            CartBottomActionBar(
                selectedItems: selectionManager.selectedElements,
                totalPrice: calculateTotalPrice(),
                onSelectAll: toggleSelectAll,
                onDelete: deleteSelectedItems,
                onCheckout: checkoutSelectedItems
            )
        }
        .task {
            setupCartItems()
        }
        .navigationTitle("购物车 (\(cartItems.count))")
        .navigationBarItems(trailing: EditButton())
    }
    
    private func setupCartItems() {
        cartItems = createSampleCartItems()
        
        // 配置选择管理
        cartSection
            .selection(selectionManager)
            .config(models: cartItems.map { SKSelectionWrapper(element: $0, isSelected: false) })
            .onCellAction(.selected) { context in
                // 切换选择状态
                selectionManager.toggleSelection(for: context.model.element)
                cartSection.reload()
            }
    }
    
    private func createSampleCartItems() -> [CartItem] {
        return [
            CartItem(
                id: "item_001",
                productName: "iPhone 15 Pro 钛金属手机壳",
                brand: "Apple",
                price: 399.0,
                originalPrice: 499.0,
                imageURL: "iphone_case.jpg",
                quantity: 1,
                isAvailable: true,
                shippingInfo: "预计2-3天送达"
            ),
            CartItem(
                id: "item_002", 
                productName: "AirPods Pro 2 无线耳机",
                brand: "Apple",
                price: 1899.0,
                originalPrice: nil,
                imageURL: "airpods.jpg",
                quantity: 1,
                isAvailable: true,
                shippingInfo: "现货，当日发送"
            ),
            CartItem(
                id: "item_003",
                productName: "MacBook Pro 16英寸 M3 Max",
                brand: "Apple", 
                price: 25999.0,
                originalPrice: 27999.0,
                imageURL: "macbook.jpg",
                quantity: 1,
                isAvailable: false,
                shippingInfo: "缺货，预计7天后到货"
            ),
            CartItem(
                id: "item_004",
                productName: "Magic Mouse 无线鼠标",
                brand: "Apple",
                price: 649.0,
                originalPrice: nil,
                imageURL: "magic_mouse.jpg",
                quantity: 2,
                isAvailable: true,
                shippingInfo: "预计明天送达"
            )
        ]
    }
    
    private func toggleSelectAll() {
        let availableItems = cartItems.filter { $0.isAvailable }
        if selectionManager.selectedElements.count == availableItems.count {
            // 全部取消选择
            selectionManager.clearSelection()
        } else {
            // 全部选择（仅选择可用商品）
            availableItems.forEach { selectionManager.select($0) }
        }
        cartSection.reload()
    }
    
    private func deleteSelectedItems() {
        let selectedIds = Set(selectionManager.selectedElements.map { $0.id })
        cartItems.removeAll { selectedIds.contains($0.id) }
        selectionManager.clearSelection()
        
        // 重新配置section
        cartSection.config(models: cartItems.map { SKSelectionWrapper(element: $0, isSelected: false) })
    }
    
    private func checkoutSelectedItems() {
        let selectedItems = selectionManager.selectedElements.filter { $0.isAvailable }
        print("结算商品: \(selectedItems.map { $0.productName })")
        // 跳转到结算页面
    }
    
    private func calculateTotalPrice() -> Double {
        return selectionManager.selectedElements
            .filter { $0.isAvailable }
            .reduce(0) { $0 + ($1.price * Double($1.quantity)) }
    }
}

// 底部操作栏组件
struct CartBottomActionBar: View {
    let selectedItems: [CartItem]
    let totalPrice: Double
    let onSelectAll: () -> Void
    let onDelete: () -> Void
    let onCheckout: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Divider()
            
            HStack {
                Button(action: onSelectAll) {
                    HStack {
                        Image(systemName: selectedItems.isEmpty ? "circle" : "checkmark.circle.fill")
                            .foregroundColor(.systemBlue)
                        Text("全选")
                    }
                }
                
                Spacer()
                
                Button("删除", action: onDelete)
                    .foregroundColor(.systemRed)
                    .disabled(selectedItems.isEmpty)
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text("合计: ¥\(String(format: "%.2f", totalPrice))")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("已选 \(selectedItems.count) 件")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Button("结算", action: onCheckout)
                    .buttonStyle(.borderedProminent)
                    .disabled(selectedItems.isEmpty)
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(.regularMaterial)
    }
}
```
        // 监听选中状态变化
        model.selectedPublisher.sink { [weak self] isSelected in
            self?.updateAppearance(selected: isSelected)
        }.store(in: &cancellables)
    }
}

class SelectableSection: SKCSingleTypeSection<SelectableCell>, SKSelectionSequenceProtocol {
    var selectableElements: [SelectableCell.Model] { models }
    
    override func item(selected row: Int) {
        // 单选模式
        self.select(at: row, isUnique: true, needInvert: false)
    }
    
    func toggleMultiSelection(at row: Int) {
        // 多选模式
        self.select(at: row, isUnique: false, needInvert: true)
    }
}
```

## 🛠️ 安装

### Swift Package Manager

在 Xcode 中添加包依赖：

```
https://github.com/linhay/SectionKit
```

或在 `Package.swift` 中添加：

```swift
dependencies: [
    .package(url: "https://github.com/linhay/SectionKit", from: "2.4.0")
]
```

### CocoaPods

在 `Podfile` 中添加：

```ruby
pod 'SectionUI', '~> 2.4.0'
```

然后运行：

```bash
pod install
```

### Carthage

在 `Cartfile` 中添加：

```
github "linhay/SectionKit" ~> 2.4.0
```

## 📋 系统要求

- iOS 13.0+
- macOS 11.0+
- Swift 5.8+
- Xcode 14.0+

## 🏗️ 核心架构

### 协议设计

SectionKit 基于协议驱动的架构设计：

- `SKLoadViewProtocol`: 定义视图的加载和生命周期
- `SKConfigurableView`: 定义数据配置接口
- `SKCSectionProtocol`: 定义 Section 的行为规范

### 数据流

```
数据模型 → Section → Cell配置 → 视图渲染
    ↑                              ↓
用户交互 ← 事件回调 ←── 用户操作 ←──┘
```

## 🔌 扩展功能

### 自定义布局

```swift
class WaterfallLayout: UICollectionViewFlowLayout {
    // 瀑布流布局实现
}

// 应用自定义布局
controller.sectionView.collectionViewLayout = WaterfallLayout()
```

### 预加载优化

```swift
section.onCellAction(.willDisplay) { context in
    if context.row >= context.section.models.count - 3 {
        // 提前加载更多数据
        loadMoreData()
    }
}
```

## 🧪 测试支持

SectionKit 提供了完整的测试工具：

```swift
import XCTest
@testable import SectionUI

class SectionKitTests: XCTestCase {
    func testSectionConfiguration() {
        let section = TestCell.wrapperToSingleTypeSection()
        section.config(models: testData)
        
        XCTAssertEqual(section.models.count, testData.count)
    }
}
```

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

### 开发环境设置

1. Fork 本项目
2. 创建特性分支: `git checkout -b feature/amazing-feature`
3. 提交更改: `git commit -m 'Add amazing feature'`
4. 推送分支: `git push origin feature/amazing-feature`
5. 创建 Pull Request

## 📄 许可证

本项目基于 [Apache License 2.0](./LICENSE) 许可证开源。

## 🙏 致谢

感谢所有为 SectionKit 贡献代码和建议的开发者们！

---

如果觉得 SectionKit 对你有帮助，请给个 ⭐️ 支持一下！
