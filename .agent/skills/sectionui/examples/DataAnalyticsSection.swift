import Combine
import SectionUI
import UIKit

// 1. Analytics & Data Example
class DataAnalyticsSection: SKCSingleTypeSection<SKWrapperView<UILabel, String>> {

    private var internalSubject = PassthroughSubject<[String], Never>()

    override init() {
        super.init()
        setupSubscription()
        setupAnalytics()
    }

    // 2. Reactive Subscription
    // Automatically updates the section when the publisher emits
    private func setupSubscription() {
        subscribe(models: internalSubject)
    }

    // 3. Impression Analytics
    // Track when specific items are displayed
    private func setupAnalytics() {
        // Log when the FIRST item is displayed
        model(displayedAt: .first) { context in
            print("Analytics: First item displayed - \(context.model)")
        }

        // Log every 5th item
        model(displayedAt: .init { $0 % 5 == 0 }) { context in
            print("Analytics: displayed item at index \(context.row)")
        }
    }

    // 4. Granular Refresh
    func updateItem(at index: Int, with newValue: String) {
        // Refresh only the specific row, no full reload
        refresh(at: index, model: newValue)
    }

    func simulateDataLoad() {
        internalSubject.send(["A", "B", "C", "D", "E", "F"])
    }

    // 5. Custom Supplementary (Decoration)
    // Register a custom background view
    func addBackground() {
        set(supplementary: .custom("Background"), type: UIView.self, model: ()) { view in
            view.backgroundColor = .systemGray6
            view.layer.zPosition = -1  // Send to back
        }
    }
}
