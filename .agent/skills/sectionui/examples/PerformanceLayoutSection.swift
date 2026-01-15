import SectionUI
import UIKit

/// Demonstrates advanced Layout control and Performance tuning.
class PerformanceLayoutSection: SKCSingleTypeSection<PerformanceLayoutSection.Cell> {

    // Mock Service for Environment Injection
    struct AnalyticsService {
        static let shared = AnalyticsService()
        func track(event: String) { print("Tracking: \(event)") }
    }

    override init() {
        super.init()
        setupLayout()
        setupEnvironment()
    }

    required init(_ models: [String] = []) {
        super.init(models)
        setupLayout()
        setupEnvironment()
    }

    private func setupLayout() {
        // 1. Force cells to be 1/2 width (2 columns)
        // using .fraction(0.5) from SKSafeSizeProvider
        cellSafeSize(.fraction(0.5))

        // 2. High Performance Caching
        // We can manually clear cache if environment changes
        highPerformance?.removeAll()
    }

    private func setupEnvironment() {
        // Inject dependencies
        environment(of: AnalyticsService.shared)

        // Use dependency in action
        onCellAction(.selected) { [weak self] context in
            // Retrieve dependency
            guard let analytics = self?.environment(of: AnalyticsService.self) else { return }
            analytics.track(event: "Selected \(context.model)")
        }
    }

    // Demonstrate 'highPerformance' usage in size calculation
    override func itemSize(at row: Int) -> CGSize {
        // Use the high-performance cache store
        // This avoids re-calculating text size on every scroll
        return highPerformance.cache(by: models[row], limit: safeSizeProvider.size) { limit in
            return Cell.preferredSize(limit: limit, model: models[row])
        }
    }

    class Cell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
        typealias Model = String

        func config(_ model: String) {
            backgroundColor = .random
        }

        static func preferredSize(limit size: CGSize, model: String?) -> CGSize {
            // Simulate expensive calculation
            return CGSize(width: size.width, height: 100)
        }
    }
}

extension UIColor {
    static var random: UIColor {
        .init(
            red: .random(in: 0...1), green: .random(in: 0...1), blue: .random(in: 0...1), alpha: 1)
    }
}
