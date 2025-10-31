
//
//  03.01-Gallery.swift
//  Example
//
//  Created by linhey on 6/16/25.
//

import SwiftUI
import SectionUI
import UIKit
import Combine

final class SelectTextCell: UICollectionViewCell, SKConfigurableView, SKLoadViewProtocol {
    
    typealias Model = SKSelectionWrapper<String>
    static let adaptive = SKAdaptive(view: SelectTextCell())
private var cancellable: AnyCancellable?
    
    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        return adaptive.adaptiveWidthFittingSize(limit: size, model: model)
    }

    func config(_ model: Model) {
        label.text = model.rawValue
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



@Observable
class SelectTextReducer: SKCRectSelectionDelegate {

    @ObservationIgnored lazy var models = [SelectTextCell.Model]()
    @ObservationIgnored lazy var sectionController = SKCollectionViewController()
    @ObservationIgnored lazy var dragSelector = SKCDragSelector()
    func reload() {
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

          We depend more and more on data and on its computation. Think for a moment about how often we use computation and data processing. This aspect can’t be not reflected in the modern apps, especially mobile ones.

          The more we go forward, the more computing power we need. Sometimes it takes additional time. From a UX perspective, we want to deliver always fresh and juicy updates to users, based on their most relevant data. If computation takes too long, the user can wait for it, and waiting is the stuff we don’t like more than other stuff.

          Concept
          One of the ways to improve this process is to use background tasks and background processing. So we just schedule periodic updates or some computations or some other activities, that “preheat” data for us.

          There are a lot of good articles about how to configure this kind of background work, like this one.

          Despite this fact, we often face issues and problems that impede our success. Implementing these activities is not the exception.

          So, I decided to put some marks here, related to the main points that need to be completed in order to succeed, because in various articles and documentation, the information is placed partially, and we need (as always) to collect it from part to part.

          Checklist
          Below is aka checklist of how to configure a background task.

          I won’t cover previous versions of the backgrounding process for iOS; instead, I will focus on the current one (at the moment of writing, we have iOS 26 as a fresh release and iOS 18 as a predecessor and still a bit in use)

          0) import BackgroundTasks ;]

          1) Enable Background Modes capabilities in project config

          If you’re using BGAppRefreshTask, select “Background fetch.”
          If you’re using BGProcessingTask, select “Background processing.”
          old_software.jpeg



          For BGTaskScheduler, Apple also recommends enabling “Background processing” when using BGProcessingTask; for BGAppRefresh, “Background fetch” is the relevant one.

          2) Register a list of your task identifiers - in Info.plist under key for array BGTaskSchedulerPermittedIdentifiers

          old_software.jpeg



          If it’s missing or mismatched, registration will fail and tasks won’t run.

          Next, u have a few options:

          using BGTaskScheduler.shared.register
          using backgroundTask modifier in SwiftUI
          with BGTaskScheduler.shared.register (Manual registration approach)
          3) Register task: BGTaskScheduler.shared.register. You must call BGTaskScheduler.shared.register(forTaskWithIdentifier:using:launchHandler:) once, early in app launch (before tasks can be delivered).

          This is important!

          Without registration, submit() will succeed, but the system will never deliver the task. This must be called once during launch, before scheduling or receiving deliveries. The SwiftUI.backgroundTask modifier does not replace registration.

          In a SwiftUI App, you typically register in the init() of your @main App or in UIApplicationDelegateAdaptor’s application(_:didFinishLaunchingWithOptions:). The .backgroundTask modifier is not a substitute for register(...).

          Disclaimer from Apple doc:

          In iOS 13 and later, adding a BGTaskSchedulerPermittedIdentifiers key to the Info.plist disables the application(:performFetchWithCompletionHandler:) and setMinimumBackgroundFetchInterval(:) methods. (source)

          4) Correctly implement registration and task handling, and use setTaskCompleted method to inform the system about the current state of the task. Don’t forget to reschedule the task. Or as an option, u can schedule a task on ScenePhase change:

          ...
          ...
          // in body somewhere
          Scene {

          }
          .onChange(of: scenePhase, { _, newPhase in
              switch newPhase {
                  case .background:
                      scheduleAppRefreshTask() // <- here
                  default:
                      break
              }
          })
          ...
          with backgroundTask modifier (Pure SwiftUI backgroundTask approach)
          3) Schedule the Task: You still need to create a request and submit it to the BGTaskScheduler. This is typically done when a scene moves to the background, for example, using the .onChange(of: scenePhase) modifier.

          Pitfall: You must be careful to schedule the task only when the scene phase becomes .background. If you try to schedule it at another time, the system may ignore it.

          Incorrect:

          .onAppear {
              // ❌ Don't schedule here. May not work
              scheduleAppRefresh()
          }
          or

          .task {
              // ❌ Don't schedule here. May not work
              scheduleAppRefresh()
          }
          4) Handle the Task with .backgroundTask: Instead of providing a launchHandler during registration, you attach the .backgroundTask modifier to a scene in your SwiftUI app. This modifier takes the task identifier and an asynchronous closure. When the system executes your scheduled task, this closure is run.

          finally
          5) To debug and test, u can use a few techniques (more details below).
          """
            .split(separator: "\n")
            .map(\.description)
            .map { text in
                text
                    .split(separator: " ")
                    .map(\.description)
            }
            .joined()
            .map({ $0 })
        
        self.models = texts.map { text in
            SelectTextCell.Model(rawValue: text)
        }
        let section = SelectTextCell
            .wrapperToSingleTypeSection(models)
            .setSectionStyle { section in
                section.sectionInset = .init(top: 32,
                                             left: 24,
                                             bottom: 32,
                                             right: 24)
                section.minimumLineSpacing = 8
                section.minimumInteritemSpacing = 2
            }
            .addLayoutPlugins(.left)
        sectionController.reloadSections(section)
        try? dragSelector.setup(collectionView: sectionController.sectionView,
                           rectSelectionDelegate: self)
    }
    
    func rectSelectionManager(_ manager: SKCRectSelectionManager, didUpdateSelection isSelected: Bool, for indexPath: IndexPath) {
        models[indexPath.row].select(isSelected)
    }
    
    func rectSelectionManager(_ manager: SKCRectSelectionManager, isSelectedAt indexPath: IndexPath) -> Bool {
        models[indexPath.row].isSelected
    }
    
    func rectSelectionManager(_ manager: SKCRectSelectionManager, willDisplay overlayView: SKSelectionOverlayView) {
        
    }
}


struct SelectTextView: View {
    
    @State var store = SelectTextReducer()
    
    var body: some View {
        VStack {
            SKUIController {
                store
                    .sectionController
                    .backgroundColor(.yellow)
            }
            .ignoresSafeArea()
            Button("reload") {
                store.reload()
            }
        }
        .task {
            store.reload()
        }
    }
    
}

#Preview {
    SelectTextView()
}
