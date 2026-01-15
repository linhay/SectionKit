import SectionUI
import SnapKit
import UIKit

class MainViewController: SKCollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SectionKit Example"
        view.backgroundColor = .systemBackground
        manager.reload([
            makeFoundationSection(),
            makeLayoutSection(),
            makeDataSection(),
            makeInteractionSection(),
            makePageSection(),
        ])
    }

    private func makeFoundationSection() -> SKCSectionProtocol {
        makeSection(
            title: "1. Foundation (基础: 合规 Cell 的构建)",
            models: [
                .init(
                    title: "Lesson 1: Standard Code-Based Cell", desc: "StandardCellViewController",
                    action: { StandardCellViewController() }),
                .init(
                    title: "Lesson 3: The Wrapper Pattern", desc: "WrapperCellViewController",
                    action: { WrapperCellViewController() }),
                .init(
                    title: "Lesson 4: Auto-Layout & Adaptive Cell",
                    desc: "AdaptiveCellViewController", action: { AdaptiveCellViewController() }),
                .init(
                    title: "Lesson 5: Minimal Setup (Hello World)",
                    desc: "HelloWorldViewController", action: { HelloWorldViewController() }),
                .init(
                    title: "Single Type Section", desc: "SingleTypeSectionViewController",
                    action: { SingleTypeSectionViewController() }),
            ])
    }

    private func makeLayoutSection() -> SKCSectionProtocol {
        makeSection(
            title: "2. Layout (布局与样式)",
            models: [
                .init(
                    title: "Grid Layout", desc: "GridColorViewController",
                    action: { GridColorViewController() }),
                .init(
                    title: "Waterfall Layout", desc: "WaterfallViewController",
                    action: { WaterfallViewController() }),
                .init(
                    title: "Header & Footer", desc: "FooterAndHeaderViewController",
                    action: { FooterAndHeaderViewController() }),
                .init(
                    title: "Decoration Views", desc: "DecorationViewController",
                    action: { DecorationViewController() }),
                .init(
                    title: "Index Titles", desc: "IndexTitlesViewController",
                    action: { IndexTitlesViewController() }),
                .init(
                    title: "Pin Index", desc: "PinIndexViewController",
                    action: { PinIndexViewController() }),
            ])
    }

    private func makeDataSection() -> SKCSectionProtocol {
        makeSection(
            title: "3. Data (数据与事件)",
            models: [
                .init(
                    title: "Multiple Sections", desc: "MultipleSectionViewController",
                    action: { MultipleSectionViewController() }),
                .init(
                    title: "Load & Pull", desc: "LoadAndPullViewController",
                    action: { LoadAndPullViewController() }),
                .init(
                    title: "Combine Subscription", desc: "SubscribeDataWithCombineViewController",
                    action: { SubscribeDataWithCombineViewController() }),
                .init(
                    title: "Select Text", desc: "SelectTextViewController",
                    action: { SelectTextViewController() }),
                .init(
                    title: "Reactive Data (@SKPublished)", desc: "ReactiveDataViewController",
                    action: { ReactiveDataViewController() }),
            ])
    }

    private func makeInteractionSection() -> SKCSectionProtocol {
        makeSection(
            title: "4. Interaction (高级交互)",
            models: [
                .init(
                    title: "Parallax", desc: "ParallaxViewController",
                    action: { ParallaxViewController() }),
                .init(
                    title: "Scroll Observer", desc: "ScrollObserverViewController",
                    action: { ScrollObserverViewController() }),
                .init(
                    title: "Gallery Performance", desc: "GalleryViewController",
                    action: { GalleryViewController() }),
            ])
    }

    private func makePageSection() -> SKCSectionProtocol {
        makeSection(
            title: "5. Page (页面与嵌套)",
            models: [
                .init(
                    title: "Standard Page Controller", desc: "PageViewController",
                    action: { PageViewController() }),
                .init(
                    title: "Nested Scroll", desc: "NestedScrollViewController",
                    action: { NestedScrollViewController() }),
            ])
    }

    private func makeSection(title: String, models: [MenuCell.Model]) -> SKCSingleTypeSection<
        MenuCell
    > {
        return MenuCell.wrapperToSingleTypeSection(models)
            .onCellAction(.selected) { [weak self] context in
                let vc = context.model.action()
                self?.navigationController?.pushViewController(vc, animated: true)
            }
            .setHeader(HeaderLabel.self, model: title) { view in
                view.backgroundColor = .secondarySystemBackground
            }
    }
}

// MARK: - Views

class HeaderLabel: UICollectionReusableView, SKLoadViewProtocol, SKConfigurableView {
    typealias Model = String

    lazy var label: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        label.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(
                UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16))
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func config(_ model: String) {
        label.text = model
    }

    static func preferredSize(limit size: CGSize, model: String?) -> CGSize {
        return .init(width: size.width, height: 40)
    }
}

class MenuCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {

    struct Model {
        let title: String
        let desc: String
        let action: () -> UIViewController
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()

    private lazy var descLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .secondaryLabel
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(titleLabel)
        contentView.addSubview(descLabel)

        titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(16)
        }

        descLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(4)
            make.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func config(_ model: Model) {
        titleLabel.text = model.title
        descLabel.text = model.desc
    }

    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return .init(width: size.width, height: 60)
    }
}
