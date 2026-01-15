import SectionUI
import UIKit

class ParentViewController: UIViewController {
    let manager = SKPageManager()
    lazy var pageVC = SKPageViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        manager.configure { m in
            m.setChilds([
                .init(id: "page1", maker: { _ in UIViewController() }),
                .init(id: "page2", maker: { _ in UIViewController() }),
                // Lightweight View-based page
                .init(
                    id: "view_page",
                    maker: { _ in
                        let view = UIView()
                        view.backgroundColor = .systemBlue
                        return view
                    }),
            ])
            m.selection = 0
            m.scrollDirection = .horizontal
        }

        pageVC.set(manager: manager)
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
    }
}
