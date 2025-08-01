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

A powerful, data-driven `UICollectionView` framework designed for building fast, flexible, and high-performance lists.

## ✨ Key Features

|           | Feature Description                                  |
| --------- | --------------------------------------------------- |
| 🏗️ | **Great Architecture** - Reusable Cell and component architecture |
| 📱 | **Multi-Data Types** - Easily create complex lists with multiple data types |
| ⚡ | **High Performance** - High-performance data processing and view reuse mechanisms |
| 🔧 | **Feature Rich** - Tons of plugins and extensions to help build perfect lists |
| 🦉 | **Modern** - Written in pure Swift with full SwiftUI support |
| 🎨 | **Flexible Layout** - Support for grids, waterfall flows, and various layout methods |

## 🚀 Quick Start

### Basic Example

Creating a simple list requires just a few lines of code:

```swift
import SectionUI
import SwiftUI

struct BasicListView: View {
    @State
    var section = TextCell
        .wrapperToSingleTypeSection()
    
    var body: some View {
        SKPreview.sections {
            section
        }
        .task {
            section.config(models: [
                .init(text: "First Row", color: .red),
                .init(text: "Second Row", color: .green),
                .init(text: "Third Row", color: .blue)
            ])
        }
    }
}
```

## 📖 Detailed Examples

### 1. [Single Type List](./Example/01-Introduction.swift)

Create the simplest single data type list:

```swift
class IntroductionCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    struct Model {
        let text: String
        let color: UIColor
    }
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return .init(width: size.width, height: 44)
    }
    
    func config(_ model: Model) {
        titleLabel.text = model.text
        contentView.backgroundColor = model.color
    }
    
    // UI component setup...
}

// Usage example
let section = IntroductionCell
    .wrapperToSingleTypeSection()
    .onCellAction(.selected) { context in
        print("Selected: \(context.model.text)")
    }

section.config(models: [
    .init(text: "Item 1", color: .systemBlue),
    .init(text: "Item 2", color: .systemGreen)
])
```

![01-Introduction](https://github.com/linhay/RepoImages/blob/main/SectionUI/01-Introduction.png?raw=true)

### 2. [Multiple Sections](./Example/02.01-MultipleSection.swift)

Create complex lists with multiple different data sources:

```swift
struct MultipleSectionView: View {
    @State var headerSection = HeaderCell.wrapperToSingleTypeSection()
    @State var dataSection = DataCell.wrapperToSingleTypeSection()
    @State var footerSection = FooterCell.wrapperToSingleTypeSection()
    
    var body: some View {
        SKPreview.sections {
            headerSection
            dataSection
            footerSection
        }
        .task {
            // Configure different data sources
            headerSection.config(models: [.init(title: "Page Title")])
            dataSection.config(models: generateDataItems())
            footerSection.config(models: [.init(info: "Page Footer Info")])
        }
    }
}
```

![02-MultipleSection](https://github.com/linhay/RepoImages/blob/main/SectionUI/02-MultipleSection.png?raw=true)

### 3. [Headers and Footers](./Example/01.03-FooterAndHeader.swift)

Add headers and footers to your lists:

```swift
let section = DataCell
    .wrapperToSingleTypeSection()
    .setSectionStyle { section in
        section.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    .supplementaryView(HeaderView.self, for: .header) { context in
        context.view().config(.init(title: "List Title"))
    }
    .supplementaryView(FooterView.self, for: .footer) { context in
        context.view().config(.init(text: "Total \(context.section.models.count) items"))
    }
```

![03-FooterAndHeader](https://github.com/linhay/RepoImages/blob/main/SectionUI/03-FooterAndHeader.png?raw=true)

### 4. [Data Loading and Refresh](./Example/04-LoadAndPull.swift)

Implement pull-to-refresh and load more:

```swift
struct LoadMoreView: View {
    @State var section = DataCell.wrapperToSingleTypeSection()
    @State var isLoading = false
    
    var body: some View {
        SKUIController {
            let controller = SKCollectionViewController()
            controller.reloadSections(section)
            
            // Pull to refresh
            controller.sectionView.refreshControl = UIRefreshControl()
            controller.sectionView.refreshControl?.addTarget(
                self, action: #selector(refreshData), 
                for: .valueChanged
            )
            
            return controller
        }
    }
    
    @objc func refreshData() {
        // Reload data
        Task {
            let newData = await fetchFreshData()
            await MainActor.run {
                section.config(models: newData)
                controller.sectionView.refreshControl?.endRefreshing()
            }
        }
    }
}
```

![04-LoadAndPull](https://github.com/linhay/RepoImages/blob/main/SectionUI/04-LoadAndPull.png?raw=true)

### 5. [Combine Data Binding](./Example/05-SubscribeDataWithCombine.swift)

Use Combine for reactive programming:

```swift
class DataViewModel: ObservableObject {
    @Published var items: [DataModel] = []
    
    func loadData() {
        // Simulate network request
        Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .map { _ in self.generateRandomData() }
            .assign(to: &$items)
    }
}

struct CombineDataView: View {
    @StateObject var viewModel = DataViewModel()
    @State var section = DataCell.wrapperToSingleTypeSection()
    
    var body: some View {
        SKPreview.sections { section }
            .onReceive(viewModel.$items) { items in
                section.config(models: items)
            }
            .task {
                viewModel.loadData()
            }
    }
}
```

![05-SubscribeDataWithCombine](https://github.com/linhay/RepoImages/blob/main/SectionUI/05-SubscribeDataWithCombine.png?raw=true)

### 6. [Grid Layout](./Example/06-Grid.swift)

Create adaptive grid layouts:

```swift
struct GridView: View {
    @State var section = ColorCell
        .wrapperToSingleTypeSection()
        .setSectionStyle { section in
            section.minimumLineSpacing = 2
            section.minimumInteritemSpacing = 2
        }
        .cellSafeSize(.fraction(0.25), transforms: .height(asRatioOfWidth: 1))
    
    var body: some View {
        SKPreview.sections { section }
            .task {
                section.config(models: (0...99).map { index in
                    .init(
                        text: "\(index)",
                        color: UIColor.random()
                    )
                })
            }
    }
}
```

![06-Grid](https://github.com/linhay/RepoImages/blob/main/SectionUI/06-Grid.png?raw=true)

### 7. [Decoration Views](./Example/07-Decoration.swift)

Add background decorations and separators:

```swift
struct DecorationView: View {
    @State var section = DataCell
        .wrapperToSingleTypeSection()
        .decorationView(BackgroundDecorationView.self) { context in
            context.view().backgroundColor = .systemGray6
        }
    
    var body: some View {
        SKPreview.sections { section }
    }
}

class BackgroundDecorationView: UICollectionReusableView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 12
        backgroundColor = .systemBackground
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowOpacity = 0.1
        layer.shadowRadius = 4
    }
}
```

![07-Decoration](https://github.com/linhay/RepoImages/blob/main/SectionUI/07-Decoration.png?raw=true)

### 8. [Index Titles](./Example/08-IndexTitles.swift)

Add sidebar index for long lists:

```swift
struct IndexTitlesView: View {
    var body: some View {
        SKPreview.sections {
            ContactCell
                .wrapperToSingleTypeSection(contacts)
                .setSectionStyle { section in
                    section.indexTitle = "Contacts"
                }
        }
    }
}
```

### 9. [Page View](./Example/10-Page.swift)

Create PageViewController-like paging effects:

```swift
struct PageView: View {
    @State private var currentPage: Int = 0
    
    var body: some View {
        SKUIController {
            let controller = SKCollectionViewController()
            let section = PageCell.wrapperToSingleTypeSection(pages)
            
            controller.reloadSections(section)
            controller.sectionView.isPagingEnabled = true
            controller.sectionView.bounces = false
            
            // Monitor scroll events
            controller.manager.scrollObserver.add { handle in
                handle.onChanged { scrollView in
                    let page = Int(scrollView.contentOffset.x / scrollView.bounds.width)
                    if page != currentPage {
                        currentPage = page
                    }
                }
            }
            
            return controller
        }
        .overlay(alignment: .bottom) {
            PageIndicator(currentPage: currentPage, totalPages: pages.count)
        }
    }
}
```

### 10. [Selection Management](./Documentation/SKSelection.md)

Advanced selection functionality support:

```swift
class SelectableCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    typealias Model = SKSelectionWrapper<DataModel>
    
    func config(_ model: Model) {
        // Listen to selection state changes
        model.selectedPublisher.sink { [weak self] isSelected in
            self?.updateAppearance(selected: isSelected)
        }.store(in: &cancellables)
    }
}

class SelectableSection: SKCSingleTypeSection<SelectableCell>, SKSelectionSequenceProtocol {
    var selectableElements: [SelectableCell.Model] { models }
    
    override func item(selected row: Int) {
        // Single selection mode
        self.select(at: row, isUnique: true, needInvert: false)
    }
    
    func toggleMultiSelection(at row: Int) {
        // Multi-selection mode
        self.select(at: row, isUnique: false, needInvert: true)
    }
}
```

## 🛠️ Installation

### Swift Package Manager

Add package dependency in Xcode:

```
https://github.com/linhay/SectionKit
```

Or add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/linhay/SectionKit", from: "2.4.0")
]
```

### CocoaPods

Add to your `Podfile`:

```ruby
pod 'SectionUI', '~> 2.4.0'
```

Then run:

```bash
pod install
```

### Carthage

Add to your `Cartfile`:

```
github "linhay/SectionKit" ~> 2.4.0
```

## 📋 Requirements

- iOS 13.0+
- macOS 11.0+
- Swift 5.8+
- Xcode 14.0+

## 🏗️ Core Architecture

### Protocol Design

SectionKit is based on protocol-driven architecture:

- `SKLoadViewProtocol`: Defines view loading and lifecycle
- `SKConfigurableView`: Defines data configuration interface
- `SKCSectionProtocol`: Defines Section behavior specifications

### Data Flow

```
Data Model → Section → Cell Configuration → View Rendering
    ↑                                            ↓
User Interaction ← Event Callbacks ←── User Actions ←──┘
```

## 🔌 Extensions

### Custom Layout

```swift
class WaterfallLayout: UICollectionViewFlowLayout {
    // Waterfall layout implementation
}

// Apply custom layout
controller.sectionView.collectionViewLayout = WaterfallLayout()
```

### Preloading Optimization

```swift
section.onCellAction(.willDisplay) { context in
    if context.row >= context.section.models.count - 3 {
        // Preload more data
        loadMoreData()
    }
}
```

## 🧪 Testing Support

SectionKit provides complete testing tools:

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

## 🤝 Contributing

Issues and Pull Requests are welcome!

### Development Environment Setup

1. Fork this project
2. Create feature branch: `git checkout -b feature/amazing-feature`
3. Commit changes: `git commit -m 'Add amazing feature'`
4. Push branch: `git push origin feature/amazing-feature`
5. Create Pull Request

## 📄 License

This project is licensed under the [Apache License 2.0](./LICENSE).

## 🙏 Acknowledgments

Thanks to all developers who contributed code and suggestions to SectionKit!

---

If SectionKit helps you, please give it a ⭐️ to show your support!