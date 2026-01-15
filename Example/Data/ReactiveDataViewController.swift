//
//  ReactiveDataViewController.swift
//  Example
//
//  Created by linhey on 1/3/25.
//

import Combine
import SectionUI
import SnapKit
import UIKit

/// Merged Example: Reactive Data Binding
///
/// Demonstrates usage of `@SKPublished` and `SKBinding` for:
/// 1. View Controller level state (ViewModel binding).
/// 2. Cell level state (Model binding).

class ReactiveViewModel {
    @SKPublished var counter = 0
}

class ReactiveDataViewController: SKCollectionViewController {

    // MARK: - View Controller State
    let viewModel = ReactiveViewModel()
    private var cancellables = Set<AnyCancellable>()

    private lazy var counterLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textAlignment = .center
        label.text = "Count: 0"
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Reactive Data"
        view.backgroundColor = .white

        setupCounterUI()
        setupCollectionUI()
    }

    private func setupCounterUI() {
        // Add a header view to the top of the collection view or above it
        // For simplicity, let's just use a Section with a Header or just a cell
        // Or actually, let's put it in the navigation item or a floating view.
        // Let's use a floating view at the bottom like in original example 12.

        let container = UIView()
        container.backgroundColor = .systemGroupedBackground
        view.addSubview(container)
        container.snp.makeConstraints { make in
            make.bottom.leading.trailing.equalToSuperview()
            make.height.equalTo(100)
        }

        container.addSubview(counterLabel)
        counterLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().inset(10)
        }

        let btn = UIButton(type: .system)
        btn.setTitle("Increment ViewModel", for: .normal)
        btn.addTarget(self, action: #selector(increment), for: .touchUpInside)
        container.addSubview(btn)
        btn.snp.makeConstraints { make in
            make.top.equalTo(counterLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }

        // Adjust collection view insets
        sectionView.contentInset.bottom = 100

        // Bind ViewModel
        viewModel.$counter.bind { [weak self] val in
            self?.counterLabel.text = "Count: \(val)"
        }.store(in: &cancellables)
    }

    @objc func increment() {
        viewModel.counter += 1
    }

    private func setupCollectionUI() {
        // MARK: - Cell State
        // Create 50 models, each with independent reactive state
        let models = (0...50).map { _ in ReactiveCell.Model() }

        let section = ReactiveCell.wrapperToSingleTypeSection(models)
            .setSectionStyle { section in
                section.minimumLineSpacing = 8
                section.minimumInteritemSpacing = 8
                section.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
            }
            .cellSafeSize(.fraction(0.25), transforms: .height(asRatioOfWidth: 1))
            .onCellAction(.selected) { context in
                // Start animation or toggle state
                context.model.isSelected.toggle()
            }
            .onCellAction(.willDisplay) { context in
                if context.model.color == nil {
                    // Assign random color if not set
                    context.model.color = [UIColor.red, .green, .blue, .orange, .purple]
                        .randomElement()
                }
            }

        manager.reload(section)
    }
}

class ReactiveCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {

    class Model {
        @SKPublished var isSelected: Bool = false
        var color: UIColor?
    }

    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return size
    }

    private var cancellables = Set<AnyCancellable>()

    func config(_ model: Model) {
        cancellables.removeAll()

        // Initial state
        contentView.backgroundColor = model.color ?? .gray

        // Reactive binding
        model.$isSelected.bind { [weak self] isSelected in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.3) {
                self.layer.borderWidth = isSelected ? 4 : 0
                self.layer.borderColor = UIColor.black.cgColor
                self.transform = isSelected ? CGAffineTransform(scaleX: 0.9, y: 0.9) : .identity
            }
        }.store(in: &cancellables)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 8
        layer.masksToBounds = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
