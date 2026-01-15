import Combine
import SectionUI
import UIKit

// 1. Enhanced Publishing (SKPublished)
class CommonViewModel {
    // Transform: Remove duplicates and filter empty strings
    @SKPublished(transform: [.removeDuplicates(), .filter { !$0.isEmpty }])
    var searchQuery: String = ""

    // Weak assignment example support
    @SKPublished var title: String = "Default Title"
}

class CommonUtilitiesExample: UIViewController {

    let viewModel = CommonViewModel()
    var cancellables = Set<AnyCancellable>()

    // 2. Reactive Binding (SKBinding)
    // Create a binding to the viewModel's search query
    lazy var queryBinding = SKBinding(on: viewModel, keyPath: \.searchQuery)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupBindings()
        testConditionalLogic()
    }

    func setupBindings() {
        // Observe changes
        queryBinding.bind { [weak self] query in
            print("Search query changed to: \(query)")
            self?.viewModel.title = "Searching: \(query)"
        }.store(in: &cancellables)

        // Weak assignment
        viewModel.$title.assign(onWeak: self, to: \.title).store(in: &cancellables)
    }

    // 3. Conditional Logic (SKWhen)
    func testConditionalLogic() {
        struct User {
            var age: Int
            var isMember: Bool
        }

        let isAdult = SKWhen<User> { $0.age >= 18 }
        let isMember = SKWhen<User> { $0.isMember }
        let canAccessVip = isAdult.and(isMember)

        let user = User(age: 20, isMember: true)
        print("Can access VIP: \(canAccessVip.validate(user))")  // true
    }

    // 4. Universal View Wrapper (SKCWrapperCell)
    // Create a section using a wrapped UIView directly
    func createWrapperSection() -> SKCSingleTypeSection<SKCWrapperCell<ConfigurableLabel>> {
        // Define a local configurable view (or use an existing one)
        class ConfigurableLabel: UILabel, SKConfigurableView {
            typealias Model = String
            func config(_ model: String) {
                text = model
                textColor = .blue
            }
        }

        return SKCWrapperCell<ConfigurableLabel>.wrapperToSingleTypeSection {
            "Item 1"
            "Item 2"
        }
    }
}
