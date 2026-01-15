import SectionUI
import UIKit

class AdvancedLayoutExample: SKCollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 1. Advanced Scrolling (Delegate Forwarding)
        manager.scrollObserver.add(scroll: "analytics_tracker") { handle in
            handle.scrollViewDidScroll = { scrollView in
                // Track scroll depth or trigger localized interactions
                // print("Scroll Offset: \(scrollView.contentOffset.y)")
            }

            handle.scrollViewWillBeginDragging = { scrollView in
                print("User started dragging")
            }
        }

        setupSection()
    }

    func setupSection() {
        let section = SKWrapperView<UILabel, String>.wrapperToSingleTypeSection {
            (0..<20).map { "Item \($0)" }
        }

        section.setCellStyle { context in
            context.view.text = context.model
            context.view.backgroundColor = .systemGray5
        }

        // 2. Custom Layout Plugin (e.g., Vertical Offset)
        // This plugin shifts every 2nd item down by 20 points
        let offsetPlugin = SKCPluginAdjustAttributes { context in
            for attributes in context.attributes {
                if attributes.indexPath.item % 2 != 0 {
                    var frame = attributes.frame
                    frame.origin.y += 20
                    attributes.frame = frame
                }
            }
            return context.attributes
        }

        // Apply the plugin to the section
        section.sectionInjection?.add(plugin: .attributes(offsetPlugin))

        manager.reload(section)
    }
}
