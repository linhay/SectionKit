import SectionUI
import SwiftUI
import UIKit

// 1. Manager Capabilities Example
class HostingViewController: SKCollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let sectionA = SKWrapperView<UILabel, String>.wrapperToSingleTypeSection(["A1", "A2"])
        let sectionB = SKWrapperView<UILabel, String>.wrapperToSingleTypeSection(["B1", "B2"])

        // Batch configuration
        manager.reload([sectionA])

        // Insert
        manager.insert(sectionB, after: sectionA)

        // Safe Scrolling
        // Scrolls to the 2nd item of sectionB safely
        manager.scroll(to: sectionB, row: 1, at: .top, animated: true)
    }

    func demoSafeDelete() {
        // Safe delete configuration
        manager.configuration.replaceDeleteWithReloadData = true
        manager.removeAll()
    }
}

// 2. SwiftUI Integration Example
struct SectionUIHostView: View {
    var body: some View {
        // Bridge SKCollectionViewController to SwiftUI
        UIViewController.sk.toSwiftUI {
            HostingViewController()
        }
        .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    SectionUIHostView()
}
