//
//  03.05-SelectTextView.swift
//  Example
//
//  Created by linhey on 6/16/25.
//

import Combine
import SectionUI
import SnapKit
import UIKit

final class SelectTextCell: UICollectionViewCell, SKConfigurableView, SKLoadViewProtocol {

    typealias Model = SKSelectionWrapper<String>
    // static let adaptive = SKAdaptive(view: SelectTextCell()) // Not easily available unless allocated.
    // SKAdaptive usually needs an instance.
    // The preferredSize call in original code:
    // static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
    //    return adaptive.adaptiveWidthFittingSize(limit: size, model: model)
    // }
    // I shall create a static instance for sizing if needed or implement sizing logic.
    // Since SKAdaptive takes a view instance, I can create one.
    private static let sizingCell = SelectTextCell()

    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        sizingCell.config(model!)  // Config to calculate size
        // Using systemLayoutSizeFitting or manual calculation?
        // Original used `adaptive.adaptiveWidthFittingSize`.
        // I will trust auto layout on sizingCell.
        let targetSize = CGSize(width: size.width, height: 0)  // height 0 for fitting? Or width flexible?
        // adaptiveWidthFittingSize usually implies fixed height, flexible width, OR fixed width, flexible height?
        // "WidthFittingSize" -> fitting width given height? No, "WidthFitting" usually means "Size Fitting Width".
        // Let's assume standard auto layout:
        sizingCell.frame = CGRect(origin: .zero, size: size)
        sizingCell.layoutIfNeeded()
        let fittingSize = sizingCell.contentView.systemLayoutSizeFitting(
            CGSize(width: size.width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        return fittingSize
    }

    private var cancellable: AnyCancellable?

    func config(_ model: Model) {
        label.text = model.rawValue
        // Reset state
        self.contentView.backgroundColor = model.isSelected ? .blue : .gray

        cancellable = model.selectedPublisher.sink { [weak self] isSelected in
            guard let self = self else { return }
            self.contentView.backgroundColor = isSelected ? .blue : .gray
        }
    }

    private lazy var label: UILabel = {
        let view = UILabel()
        view.font = .systemFont(ofSize: 16, weight: .regular)
        view.textColor = .white
        view.textAlignment = .center
        view.numberOfLines = 0
        // Priorities from original
        view.setContentHuggingPriority(.defaultHigh, for: .vertical)
        view.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .gray
        contentView.layer.cornerRadius = 2
        contentView.layer.masksToBounds = true
        contentView.addSubview(label)
        label.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(6)
            make.left.right.equalToSuperview().inset(8)
            make.width.greaterThanOrEqualTo(16)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class SelectTextViewController: SKCollectionViewController, SKCRectSelectionDelegate {

    var models = [SelectTextCell.Model]()
    lazy var dragSelector = SKCDragSelector()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "03.05-SelectText"
        view.backgroundColor = .white

        // Data setup
        let texts = """
            Concept
            Checklist
            with BGTaskScheduler.shared.register (Manual registration approach)
            with backgroundTask modifier (Pure SwiftUI backgroundTask approach)
            finally
            Debuging and Pitfalls
            simulation
            better testing with visual feedback
            typos
            timing
            mix
            Code
            Manual registration approach
            Pure SwiftUI backgroundTask approach
            Conclusion
            Resources
            We depend more and more on data and on its computation. Think for a moment about how often we use computation and data processing.
            Concept
            One of the ways to improve this process is to use background tasks.
            Checklist
            0) import BackgroundTasks ;]
            1) Enable Background Modes capabilities in project config
            If you’re using BGAppRefreshTask, select “Background fetch.”
            If you’re using BGProcessingTask, select “Background processing.”
            For BGTaskScheduler, Apple also recommends enabling “Background processing”.
            2) Register a list of your task identifiers.
            If it’s missing or mismatched, registration will fail.
            3) Register task: BGTaskScheduler.shared.register.
            This is important!
            Without registration, submit() will succeed, but the system will never deliver the task.
            In a SwiftUI App, you typically register in the init().
            Disclaimer from Apple doc:
            In iOS 13 and later, adding a key to the Info.plist disables application methods.
            4) Correctly implement registration and task handling.
            Scene { } .onChange(of: scenePhase) { ... }
            with backgroundTask modifier (Pure SwiftUI backgroundTask approach)
            3) Schedule the Task: You still need to create a request.
            Pitfall: You must be careful to schedule the task only when the scene phase becomes .background.
            Incorrect: .onAppear { scheduleAppRefresh() }
            4) Handle the Task with .backgroundTask.
            finally
            5) To debug and test, u can use a few techniques.
            """
            .split(separator: "\n")
            .map(\.description)
            .flatMap { text in
                text.split(separator: " ").map(\.description)
            }

        self.models = texts.map { text in
            SelectTextCell.Model(rawValue: text)
        }

        let section =
            SelectTextCell
            .wrapperToSingleTypeSection(models)
            .setSectionStyle { section in
                section.sectionInset = .init(
                    top: 32,
                    left: 24,
                    bottom: 32,
                    right: 24)
                section.minimumLineSpacing = 8
                section.minimumInteritemSpacing = 2
            }
            .addLayoutPlugins(.left)

        manager.reload(section)

        // Drag Selector
        try? dragSelector.setup(
            collectionView: sectionView,
            rectSelectionDelegate: self)

        // Reload Button
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Reload", style: .plain, target: self, action: #selector(reload))
    }

    @objc func reload() {
        let section =
            SelectTextCell
            .wrapperToSingleTypeSection(models)
            .setSectionStyle { section in
                section.sectionInset = .init(
                    top: 32,
                    left: 24,
                    bottom: 32,
                    right: 24)
                section.minimumLineSpacing = 8
                section.minimumInteritemSpacing = 2
            }
            .addLayoutPlugins(.left)
        manager.reload(section)
    }

    // MARK: - SKCRectSelectionDelegate
    func rectSelectionManager(
        _ manager: SKCRectSelectionManager, didUpdateSelection isSelected: Bool,
        for indexPath: IndexPath
    ) {
        if indexPath.row < models.count {
            models[indexPath.row].select(isSelected)
        }
    }

    func rectSelectionManager(_ manager: SKCRectSelectionManager, isSelectedAt indexPath: IndexPath)
        -> Bool
    {
        if indexPath.row < models.count {
            return models[indexPath.row].isSelected
        }
        return false
    }

    func rectSelectionManager(
        _ manager: SKCRectSelectionManager, willDisplay overlayView: SKSelectionOverlayView
    ) {

    }
}
