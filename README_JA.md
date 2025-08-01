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

高速で柔軟性があり、高性能なリストを構築するために設計された強力でデータ駆動型の `UICollectionView` フレームワークです。

## ✨ 主要機能

|           | 機能説明                                    |
| --------- | ------------------------------------------ |
| 🏗️ | **優れたアーキテクチャ** - 再利用可能なCellとコンポーネントアーキテクチャ |
| 📱 | **マルチデータ型** - 複数のデータ型を使った複雑なリストを簡単に作成 |
| ⚡ | **高性能** - 高性能なデータ処理とビューの再利用メカニズム |
| 🔧 | **機能豊富** - 完璧なリストを作るためのプラグインと拡張機能が豊富 |
| 🦉 | **モダン** - 純粋なSwiftで書かれ、SwiftUIを完全サポート |
| 🎨 | **柔軟なレイアウト** - グリッド、ウォーターフォール、各種レイアウト方式をサポート |

## 🚀 クイックスタート

### 基本例

シンプルなリストの作成は数行のコードだけで可能です：

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
                .init(text: "最初の行", color: .red),
                .init(text: "二番目の行", color: .green),
                .init(text: "三番目の行", color: .blue)
            ])
        }
    }
}
```

## 📖 詳細な例

### 1. [単一型リスト](./Example/01-Introduction.swift)

最もシンプルな単一データ型リストの作成：

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
    
    // UIコンポーネントの設定...
}

// 使用例
let section = IntroductionCell
    .wrapperToSingleTypeSection()
    .onCellAction(.selected) { context in
        print("選択されました: \(context.model.text)")
    }

section.config(models: [
    .init(text: "アイテム 1", color: .systemBlue),
    .init(text: "アイテム 2", color: .systemGreen)
])
```

![01-Introduction](https://github.com/linhay/RepoImages/blob/main/SectionUI/01-Introduction.png?raw=true)

### 2. [複数セクション](./Example/02.01-MultipleSection.swift)

異なるデータソースを持つ複雑なリストの作成：

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
            // 異なるデータソースの設定
            headerSection.config(models: [.init(title: "ページタイトル")])
            dataSection.config(models: generateDataItems())
            footerSection.config(models: [.init(info: "ページフッター情報")])
        }
    }
}
```

![02-MultipleSection](https://github.com/linhay/RepoImages/blob/main/SectionUI/02-MultipleSection.png?raw=true)

### 3. [ヘッダーとフッター](./Example/01.03-FooterAndHeader.swift)

リストにヘッダーとフッターを追加：

```swift
let section = DataCell
    .wrapperToSingleTypeSection()
    .setSectionStyle { section in
        section.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    .supplementaryView(HeaderView.self, for: .header) { context in
        context.view().config(.init(title: "リストタイトル"))
    }
    .supplementaryView(FooterView.self, for: .footer) { context in
        context.view().config(.init(text: "合計 \(context.section.models.count) 項目"))
    }
```

![03-FooterAndHeader](https://github.com/linhay/RepoImages/blob/main/SectionUI/03-FooterAndHeader.png?raw=true)

### 4. [データロードとリフレッシュ](./Example/04-LoadAndPull.swift)

プルリフレッシュとさらに読み込みの実装：

```swift
struct LoadMoreView: View {
    @State var section = DataCell.wrapperToSingleTypeSection()
    @State var isLoading = false
    
    var body: some View {
        SKUIController {
            let controller = SKCollectionViewController()
            controller.reloadSections(section)
            
            // プルリフレッシュ
            controller.sectionView.refreshControl = UIRefreshControl()
            controller.sectionView.refreshControl?.addTarget(
                self, action: #selector(refreshData), 
                for: .valueChanged
            )
            
            return controller
        }
    }
    
    @objc func refreshData() {
        // データの再読み込み
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

### 5. [Combineデータバインディング](./Example/05-SubscribeDataWithCombine.swift)

リアクティブプログラミングでCombineを使用：

```swift
class DataViewModel: ObservableObject {
    @Published var items: [DataModel] = []
    
    func loadData() {
        // ネットワークリクエストのシミュレート
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

### 6. [グリッドレイアウト](./Example/06-Grid.swift)

適応的グリッドレイアウトの作成：

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

### 7. [装飾ビュー](./Example/07-Decoration.swift)

背景装飾とセパレーターの追加：

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

### 8. [インデックスタイトル](./Example/08-IndexTitles.swift)

長いリストにサイドバーインデックスを追加：

```swift
struct IndexTitlesView: View {
    var body: some View {
        SKPreview.sections {
            ContactCell
                .wrapperToSingleTypeSection(contacts)
                .setSectionStyle { section in
                    section.indexTitle = "連絡先"
                }
        }
    }
}
```

### 9. [ページビュー](./Example/10-Page.swift)

PageViewControllerのようなページング効果の作成：

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
            
            // スクロールイベントの監視
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

### 10. [選択管理](./Documentation/SKSelection.md)

高度な選択機能のサポート：

```swift
class SelectableCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    typealias Model = SKSelectionWrapper<DataModel>
    
    func config(_ model: Model) {
        // 選択状態の変更を監視
        model.selectedPublisher.sink { [weak self] isSelected in
            self?.updateAppearance(selected: isSelected)
        }.store(in: &cancellables)
    }
}

class SelectableSection: SKCSingleTypeSection<SelectableCell>, SKSelectionSequenceProtocol {
    var selectableElements: [SelectableCell.Model] { models }
    
    override func item(selected row: Int) {
        // 単一選択モード
        self.select(at: row, isUnique: true, needInvert: false)
    }
    
    func toggleMultiSelection(at row: Int) {
        // 複数選択モード
        self.select(at: row, isUnique: false, needInvert: true)
    }
}
```

## 🛠️ インストール

### Swift Package Manager

Xcodeでパッケージ依存関係を追加：

```
https://github.com/linhay/SectionKit
```

または `Package.swift` に追加：

```swift
dependencies: [
    .package(url: "https://github.com/linhay/SectionKit", from: "2.4.0")
]
```

### CocoaPods

`Podfile` に追加：

```ruby
pod 'SectionUI', '~> 2.4.0'
```

そして実行：

```bash
pod install
```

### Carthage

`Cartfile` に追加：

```
github "linhay/SectionKit" ~> 2.4.0
```

## 📋 必要条件

- iOS 13.0+
- macOS 11.0+
- Swift 5.8+
- Xcode 14.0+

## 🏗️ コアアーキテクチャ

### プロトコル設計

SectionKitはプロトコル駆動アーキテクチャに基づいています：

- `SKLoadViewProtocol`: ビューのロードとライフサイクルを定義
- `SKConfigurableView`: データ設定インターフェースを定義
- `SKCSectionProtocol`: Sectionの動作仕様を定義

### データフロー

```
データモデル → セクション → セル設定 → ビューレンダリング
    ↑                                      ↓
ユーザーインタラクション ← イベントコールバック ←── ユーザーアクション ←──┘
```

## 🔌 拡張機能

### カスタムレイアウト

```swift
class WaterfallLayout: UICollectionViewFlowLayout {
    // ウォーターフォールレイアウトの実装
}

// カスタムレイアウトの適用
controller.sectionView.collectionViewLayout = WaterfallLayout()
```

### プリロード最適化

```swift
section.onCellAction(.willDisplay) { context in
    if context.row >= context.section.models.count - 3 {
        // さらにデータを事前読み込み
        loadMoreData()
    }
}
```

## 🧪 テストサポート

SectionKitは完全なテストツールを提供：

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

## 🤝 コントリビューション

IssueとPull Requestを歓迎します！

### 開発環境のセットアップ

1. このプロジェクトをフォーク
2. 機能ブランチを作成: `git checkout -b feature/amazing-feature`
3. 変更をコミット: `git commit -m 'Add amazing feature'`
4. ブランチをプッシュ: `git push origin feature/amazing-feature`
5. Pull Requestを作成

## 📄 ライセンス

このプロジェクトは [Apache License 2.0](./LICENSE) でライセンスされています。

## 🙏 謝辞

SectionKitにコードと提案を貢献してくださったすべての開発者の皆様に感謝いたします！

---

SectionKitがお役に立ちましたら、⭐️ でサポートをお願いします！