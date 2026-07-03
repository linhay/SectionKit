import Combine
@testable import SectionKit
import Testing
import UIKit

private final class SectionKitTestCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    struct Model {
        let id: Int
        let title: String
    }
    
    private(set) var title = ""

    func config(_ model: Model) {
        title = model.title
    }

    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        .init(width: size.width, height: 44)
    }
}

@Suite("SKCSingleTypeSection")
struct SKCSingleTypeSectionTests {

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("difference reload updates unbound models")
    func differenceReloadUpdatesUnboundModels() {
        let section = SectionKitTestCell.wrapperToSingleTypeSection([
            .init(id: 1, title: "A"),
            .init(id: 2, title: "B"),
        ])
        section.reloadKind = .difference(by: \.id)

        section.apply([
            .init(id: 1, title: "A+"),
            .init(id: 3, title: "C"),
        ])

        #expect(section.models.map(\.title) == ["A+", "C"])
    }

    @MainActor
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("difference reload on bound collection view does not nest batch updates")
    func differenceReloadBoundCollectionViewDoesNotNestBatchUpdates() async throws {
        let collectionView = UICollectionView(
            frame: .init(x: 0, y: 0, width: 320, height: 480),
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        let manager = SKCManager(sectionView: collectionView)
        let section = SectionKitTestCell.wrapperToSingleTypeSection([
            .init(id: 1, title: "A"),
            .init(id: 2, title: "B"),
            .init(id: 3, title: "C"),
        ])
        section.reloadKind = .difference(by: \.id)

        manager.reload(section)
        collectionView.layoutIfNeeded()
        #expect(collectionView.numberOfItems(inSection: 0) == 3)

        section.apply([
            .init(id: 1, title: "A+"),
            .init(id: 3, title: "C+"),
            .init(id: 4, title: "D"),
        ])

        try await Task.sleep(nanoseconds: 200_000_000)
        #expect(section.models.map(\.id) == [1, 3, 4])
        #expect(collectionView.numberOfItems(inSection: 0) == 3)
    }
    
    @MainActor
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("difference reload refreshes visible equivalent rows")
    func differenceReloadRefreshesVisibleEquivalentRows() async throws {
        let collectionView = UICollectionView(
            frame: .init(x: 0, y: 0, width: 320, height: 480),
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        let window = UIWindow(frame: collectionView.bounds)
        window.addSubview(collectionView)
        window.isHidden = false
        let manager = SKCManager(sectionView: collectionView)
        let section = SectionKitTestCell.wrapperToSingleTypeSection([
            .init(id: 1, title: "A"),
            .init(id: 2, title: "B"),
        ])
        section.reloadKind = .difference(by: \.id)
        
        manager.reload(section)
        collectionView.layoutIfNeeded()
        let firstCell = try #require(collectionView.cellForItem(at: .init(item: 0, section: 0)) as? SectionKitTestCell)
        #expect(firstCell.title == "A")
        
        section.apply([
            .init(id: 1, title: "A+"),
            .init(id: 2, title: "B+"),
        ])
        try await Task.sleep(nanoseconds: 200_000_000)
        collectionView.layoutIfNeeded()
        
        let refreshedCell = try #require(collectionView.cellForItem(at: .init(item: 0, section: 0)) as? SectionKitTestCell)
        #expect(refreshedCell.title == "A+")
        #expect(section.models.map(\.title) == ["A+", "B+"])
        #expect(collectionView.numberOfItems(inSection: 0) == 2)
    }

    @MainActor
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("difference reload handles insert-only and delete-only bound updates")
    func differenceReloadHandlesInsertOnlyAndDeleteOnlyBoundUpdates() async throws {
        let collectionView = UICollectionView(
            frame: .init(x: 0, y: 0, width: 320, height: 480),
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        let manager = SKCManager(sectionView: collectionView)
        let section = SectionKitTestCell.wrapperToSingleTypeSection([
            .init(id: 1, title: "A"),
            .init(id: 2, title: "B"),
        ])
        section.reloadKind = .difference(by: \.id)

        manager.reload(section)
        collectionView.layoutIfNeeded()

        section.apply([
            .init(id: 0, title: "Z"),
            .init(id: 1, title: "A"),
            .init(id: 2, title: "B"),
            .init(id: 3, title: "C"),
        ])
        try await Task.sleep(nanoseconds: 200_000_000)
        #expect(section.models.map(\.id) == [0, 1, 2, 3])
        #expect(collectionView.numberOfItems(inSection: 0) == 4)

        section.apply([
            .init(id: 1, title: "A"),
        ])
        try await Task.sleep(nanoseconds: 200_000_000)
        #expect(section.models.map(\.id) == [1])
        #expect(collectionView.numberOfItems(inSection: 0) == 1)
    }

    @MainActor
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("difference reload handles empty bound transitions")
    func differenceReloadHandlesEmptyBoundTransitions() async throws {
        let collectionView = UICollectionView(
            frame: .init(x: 0, y: 0, width: 320, height: 480),
            collectionViewLayout: UICollectionViewFlowLayout()
        )
        let manager = SKCManager(sectionView: collectionView)
        let section = SectionKitTestCell.wrapperToSingleTypeSection()
        section.reloadKind = .difference(by: \.id)

        manager.reload(section)
        collectionView.layoutIfNeeded()
        #expect(collectionView.numberOfItems(inSection: 0) == 0)

        section.apply([
            .init(id: 1, title: "A"),
            .init(id: 2, title: "B"),
        ])
        try await Task.sleep(nanoseconds: 200_000_000)
        #expect(section.models.map(\.id) == [1, 2])
        #expect(collectionView.numberOfItems(inSection: 0) == 2)

        section.apply([])
        try await Task.sleep(nanoseconds: 200_000_000)
        #expect(section.models.isEmpty)
        #expect(collectionView.numberOfItems(inSection: 0) == 0)
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("stateful load more gates repeated triggers")
    func statefulLoadMoreGatesRepeatedTriggers() {
        let prefetch = SKCPrefetch(count: { 2 })
        var cancellables = Set<AnyCancellable>()
        var hits = 0

        prefetch.statefulLoadMorePublisher
            .sink { hits += 1 }
            .store(in: &cancellables)

        prefetch.prefetch.send([1])
        prefetch.prefetch.send([1])
        #expect(hits == 1)
        #expect(prefetch.loadMoreState == .loading)

        prefetch.finishLoadMore()
        prefetch.prefetch.send([1])
        #expect(hits == 2)

        prefetch.finishLoadMore(hasMore: false)
        prefetch.prefetch.send([1])
        #expect(hits == 2)
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("load more supports custom prefetch threshold")
    func loadMoreSupportsCustomPrefetchThreshold() {
        let prefetch = SKCPrefetch(count: { 10 })
        var cancellables = Set<AnyCancellable>()
        var hits = 0

        prefetch.loadMorePublisher
            .sink { hits += 1 }
            .store(in: &cancellables)

        prefetch.prefetch.send([7])
        #expect(hits == 0)

        prefetch.loadMoreThreshold = 2
        prefetch.prefetch.send([7])
        #expect(hits == 1)

        prefetch.prefetch.send([0])
        #expect(hits == 1)
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("load more threshold handles empty, negative, and oversized values")
    func loadMoreThresholdBoundaryValues() {
        var itemCount = 0
        let prefetch = SKCPrefetch(count: { itemCount })
        var cancellables = Set<AnyCancellable>()
        var hits = 0

        prefetch.loadMorePublisher
            .sink { hits += 1 }
            .store(in: &cancellables)

        prefetch.loadMoreThreshold = 10
        prefetch.prefetch.send([0])
        #expect(hits == 0)

        itemCount = 5
        prefetch.loadMoreThreshold = -10
        prefetch.prefetch.send([3])
        #expect(hits == 0)
        prefetch.prefetch.send([4])
        #expect(hits == 1)

        prefetch.loadMoreThreshold = 10
        prefetch.prefetch.send([0])
        #expect(hits == 2)
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("load more threshold uses max prefetched row and exact boundary")
    func loadMoreThresholdUsesMaxPrefetchedRowAndExactBoundary() {
        let prefetch = SKCPrefetch(count: { 20 })
        var cancellables = Set<AnyCancellable>()
        var hits = 0

        prefetch.loadMoreThreshold = 3
        prefetch.loadMorePublisher
            .sink { hits += 1 }
            .store(in: &cancellables)

        prefetch.prefetch.send([])
        #expect(hits == 0)

        prefetch.prefetch.send([0, 4, 15])
        #expect(hits == 0)

        prefetch.prefetch.send([0, 4, 16])
        #expect(hits == 1)

        prefetch.prefetch.send([19, 3, 7])
        #expect(hits == 2)
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("stateful load more retries after failure and stays blocked after no more")
    func statefulLoadMoreRetriesAfterFailureAndBlocksAfterNoMore() {
        let prefetch = SKCPrefetch(count: { 5 })
        var cancellables = Set<AnyCancellable>()
        var hits = 0

        prefetch.statefulLoadMorePublisher
            .sink { hits += 1 }
            .store(in: &cancellables)

        prefetch.prefetch.send([4])
        #expect(hits == 1)
        #expect(prefetch.loadMoreState == .loading)

        prefetch.failLoadMore()
        prefetch.prefetch.send([4])
        #expect(hits == 2)
        #expect(prefetch.loadMoreState == .loading)

        prefetch.finishLoadMore(hasMore: false)
        prefetch.prefetch.send([4])
        #expect(hits == 2)

        prefetch.setLoadMoreState(.idle)
        prefetch.prefetch.send([4])
        #expect(hits == 3)
    }

}
