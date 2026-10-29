import Combine
@testable import SectionKit
import SectionUI
import Testing
import UIKit

private final class ReactiveRow {
    let id: Int
    @SKPublished var title = "Initial"
    @SKPublished var imageURL: URL? = URL(string: "https://example.com/image.png")

    init(_ id: Int) { self.id = id }
}

private final class ReactiveCell: UICollectionViewCell, SKLoadViewProtocol, SKConfigurableView {
    typealias Model = ReactiveRow
    private var subscriptions = Set<AnyCancellable>()
    private var requestedURL: URL?
    private(set) var title = ""
    private(set) var imageRequests = 0
    private(set) var configurations = 0

    func config(_ model: Model) {
        configurations += 1
        subscriptions.removeAll()
        model.$title.bind { [weak self] in self?.title = $0 }.store(in: &subscriptions)
        model.$imageURL.bind { [weak self] url in
            guard let self, self.requestedURL != url else { return }
            self.requestedURL = url
            // A request spy: production code cancels the previous request and loads
            // through its image pipeline here, guarded by the current URL.
            self.imageRequests += 1
        }.store(in: &subscriptions)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.removeAll()
        requestedURL = nil
        title = ""
    }

    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        CGSize(width: size.width, height: 44)
    }
}

private final class ReactiveHeaderModel {
    @SKPublished var title = "Items"
    @SKPublished var count = 0
    @SKPublished var status = "Ready"
    var height: CGFloat = 44
}

private final class ReactiveHeader: UICollectionReusableView, SKLoadViewProtocol, SKConfigurableView {
    typealias Model = ReactiveHeaderModel
    private var subscriptions = Set<AnyCancellable>()
    let titleLabel = UILabel()
    let countLabel = UILabel()
    let statusLabel = UILabel()
    private(set) var countDeliveries = 0

    func config(_ model: Model) {
        subscriptions.removeAll()
        // Prepend renders immediately; removeDuplicates also filters the deferred
        // CurrentValueSubject replay (unlike bind's separate immediate callback).
        model.$title.prepend(model.title).removeDuplicates()
            .sink { [weak self] in self?.titleLabel.text = $0 }.store(in: &subscriptions)
        model.$count.prepend(model.count).removeDuplicates()
            .sink { [weak self] in
                self?.countLabel.text = String($0)
                self?.countDeliveries += 1
            }.store(in: &subscriptions)
        model.$status.prepend(model.status).removeDuplicates()
            .sink { [weak self] in self?.statusLabel.text = $0 }.store(in: &subscriptions)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        subscriptions.removeAll()
    }

    static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        CGSize(width: size.width, height: model?.height ?? 44)
    }
}

private final class RecordingCollectionView: UICollectionView {
    var operations: [String] = []
    var batchCompleted: (() -> Void)?

    override func reloadData() { operations.append("reloadData"); super.reloadData() }
    override func reloadSections(_ sections: IndexSet) {
        operations.append("reloadSections"); super.reloadSections(sections)
    }
    override func reloadItems(at indexPaths: [IndexPath]) {
        operations.append("reloadItems"); super.reloadItems(at: indexPaths)
    }
    override func insertItems(at indexPaths: [IndexPath]) {
        operations.append("insertItems"); super.insertItems(at: indexPaths)
    }
    override func deleteItems(at indexPaths: [IndexPath]) {
        operations.append("deleteItems"); super.deleteItems(at: indexPaths)
    }
    override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
        operations.append("batch")
        super.performBatchUpdates(updates) { finished in
            completion?(finished)
            let callback = self.batchCompleted
            self.batchCompleted = nil
            callback?()
        }
    }
}

@MainActor
private final class ReactiveFixture {
    let view = RecordingCollectionView(
        frame: CGRect(x: 0, y: 0, width: 320, height: 480),
        collectionViewLayout: UICollectionViewFlowLayout()
    )
    let window: UIWindow
    let manager: SKCManager
    let section: SKCSingleTypeSection<ReactiveCell>
    let header = ReactiveHeaderModel()

    init(_ rows: [ReactiveRow], structuralOnly: Bool = true, useSectionUILayout: Bool = false) {
        if useSectionUILayout { view.collectionViewLayout = SKCollectionFlowLayout() }
        window = UIWindow(frame: view.bounds)
        manager = SKCManager(sectionView: view)
        section = ReactiveCell.wrapperToSingleTypeSection(rows)
        section.reloadKind = .difference(by: \.id)
        if structuralOnly { section.differenceReloadPolicy = .structuralOnly }
        section.setHeader(ReactiveHeader.self, model: header)
        window.addSubview(view)
        window.isHidden = false
        manager.reload(section)
        view.layoutIfNeeded()
        view.operations.removeAll()
    }

    func cell(_ row: Int) throws -> ReactiveCell {
        try #require(view.cellForItem(at: IndexPath(item: row, section: 0)) as? ReactiveCell)
    }

    func apply(_ rows: [ReactiveRow]) async {
        await withCheckedContinuation { continuation in
            view.batchCompleted = { continuation.resume() }
            section.apply(rows)
        }
        view.layoutIfNeeded()
    }
}

@MainActor
@Suite("Stable reactive bindings", .serialized)
struct ReactiveBindingTests {
    // Drain the deferred SKPublished delivery queue without a wall-clock delay.
    private func deliverPublishedValues() async {
        await withCheckedContinuation { continuation in
            DispatchQueue.main.async { continuation.resume() }
        }
    }

    @Test("identity-only no-op, including empty, performs no collection operations")
    func noOp() throws {
        for rows in [[], [ReactiveRow(1), ReactiveRow(2)]] {
            let fixture = ReactiveFixture(rows)
            fixture.section.apply(rows)
            #expect(fixture.view.operations.isEmpty)
            #expect(fixture.section.models.map(\.id) == rows.map(\.id))
        }
    }

    @Test("unbound structural updates store models")
    func unbound() {
        let section = ReactiveCell.wrapperToSingleTypeSection([ReactiveRow(1)])
        section.reloadKind = .difference(by: \.id)
        section.differenceReloadPolicy = .structuralOnly
        let row = ReactiveRow(2)
        section.apply([row])
        #expect(section.models.first === row)
        section.apply([])
        #expect(section.models.isEmpty)
    }

    @Test("count-only supplementary updates preserve cells and image requests", arguments: [false, true])
    func headerContent(useSectionUILayout: Bool) async throws {
        let rows = [ReactiveRow(1), ReactiveRow(2)]
        let fixture = ReactiveFixture(rows, useSectionUILayout: useSectionUILayout)
        let cell = try fixture.cell(0)
        let configurations = cell.configurations
        let header = try #require(fixture.view.supplementaryView(
            forElementKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: 0)) as? ReactiveHeader)
        for count in 1...10 { fixture.header.count = count }
        fixture.header.count = 10
        fixture.header.title = "Updated"
        fixture.header.status = "Complete"
        rows[0].title = "Progress"
        rows[0].imageURL = rows[0].imageURL
        await deliverPublishedValues()
        #expect(header.countLabel.text == "10")
        #expect(header.countDeliveries == 11)
        #expect(header.titleLabel.text == "Updated")
        #expect(header.statusLabel.text == "Complete")
        #expect(cell.title == "Progress")
        #expect(cell.configurations == configurations)
        #expect(cell.imageRequests == 1)
        #expect(fixture.view.operations.isEmpty)
    }

    @Test("insert/delete retains existing cells, subscriptions and image requests", arguments: [false, true])
    func structuralChanges(useSectionUILayout: Bool) async throws {
        let rows = [ReactiveRow(1), ReactiveRow(2)]
        let fixture = ReactiveFixture(rows, useSectionUILayout: useSectionUILayout)
        let first = try fixture.cell(0)
        let second = try fixture.cell(1)
        let firstConfigurations = first.configurations
        let secondConfigurations = second.configurations
        await fixture.apply([ReactiveRow(0)] + rows)
        #expect(try fixture.cell(1) === first)
        #expect(try fixture.cell(2) === second)
        await fixture.apply(rows)
        #expect(try fixture.cell(0) === first)
        #expect(try fixture.cell(1) === second)
        rows[0].title = "Still bound"
        await deliverPublishedValues()
        #expect(first.title == "Still bound")
        #expect(first.configurations == firstConfigurations)
        #expect(second.configurations == secondConfigurations)
        #expect(first.imageRequests == 1)
        #expect(second.imageRequests == 1)
        #expect(fixture.view.operations == ["batch", "insertItems", "batch", "deleteItems"])
    }

    @Test("empty transitions update item counts and supplementary layout", arguments: [false, true])
    func emptyTransitions(useSectionUILayout: Bool) async {
        let fixture = ReactiveFixture([], useSectionUILayout: useSectionUILayout)
        #expect(fixture.section.headerSize == .zero)
        await fixture.apply([ReactiveRow(1)])
        #expect(fixture.view.numberOfItems(inSection: 0) == 1)
        #expect(fixture.section.headerSize.height == 44)
        #expect(fixture.view.collectionViewLayout.layoutAttributesForSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader,
            at: IndexPath(item: 0, section: 0))?.size.height == 44)
        await fixture.apply([])
        #expect(fixture.view.numberOfItems(inSection: 0) == 0)
        #expect(fixture.section.headerSize == .zero)
        #expect(!fixture.view.operations.contains("reloadSections"))
    }

    @Test("reordering produces the requested model and visible cell order")
    func reorder() async throws {
        let rows = [ReactiveRow(1), ReactiveRow(2), ReactiveRow(3)]
        for row in rows { row.title = String(row.id) }
        let fixture = ReactiveFixture(rows)
        await fixture.apply([rows[2], rows[0], rows[1]])
        #expect(fixture.section.models.map(\.id) == [3, 1, 2])
        #expect(try fixture.cell(0).title == "3")
        #expect(try fixture.cell(1).title == "1")
        #expect(try fixture.cell(2).title == "2")
        #expect(!fixture.view.operations.contains("reloadItems"))
    }

    @Test("default difference still refreshes replaced payloads after no-op and insertion")
    func defaultPolicy() async throws {
        let fixture = ReactiveFixture([ReactiveRow(1)], structuralOnly: false)
        let replacement = ReactiveRow(1)
        replacement.title = "Replacement"
        fixture.section.apply([replacement])
        fixture.view.layoutIfNeeded()
        #expect(try fixture.cell(0).title == "Replacement")
        #expect(fixture.view.operations.contains("reloadItems"))
        fixture.view.operations.removeAll()
        let next = ReactiveRow(1)
        next.title = "After insertion"
        await fixture.apply([next, ReactiveRow(2)])
        #expect(try fixture.cell(0).title == "After insertion")
        #expect(fixture.view.operations.contains("reloadItems"))
    }

    @Test("reuse and reconfiguration cancel old supplementary and cell subscriptions")
    func reuse() async {
        let header = ReactiveHeader()
        let old = ReactiveHeaderModel()
        let next = ReactiveHeaderModel()
        header.config(old)
        header.prepareForReuse()
        old.count = 5
        await deliverPublishedValues()
        #expect(header.countLabel.text == "0")
        header.config(old)
        header.config(next)
        old.count = 99
        next.count = 2
        await deliverPublishedValues()
        #expect(header.countLabel.text == "2")

        let cell = ReactiveCell()
        let oldRow = ReactiveRow(1)
        let nextRow = ReactiveRow(2)
        cell.config(oldRow)
        cell.config(oldRow)
        await deliverPublishedValues()
        #expect(cell.imageRequests == 1)
        cell.prepareForReuse()
        oldRow.title = "Stale"
        await deliverPublishedValues()
        #expect(cell.title.isEmpty)
        cell.config(nextRow)
        oldRow.title = "Still stale"
        nextRow.title = "New"
        await deliverPublishedValues()
        #expect(cell.title == "New")
        #expect(cell.imageRequests == 2)
    }

    @Test("layout-only header changes invalidate geometry without reconfiguring cells", arguments: [false, true])
    func headerLayout(useSectionUILayout: Bool) throws {
        let fixture = ReactiveFixture([ReactiveRow(1)], useSectionUILayout: useSectionUILayout)
        let cell = try fixture.cell(0)
        let configurations = cell.configurations
        fixture.header.height = 80
        fixture.view.collectionViewLayout.invalidateLayout()
        fixture.view.layoutIfNeeded()
        let attributes = fixture.view.collectionViewLayout.layoutAttributesForSupplementaryView(
            ofKind: UICollectionView.elementKindSectionHeader, at: IndexPath(item: 0, section: 0))
        #expect(attributes?.size.height == 80)
        #expect(cell.configurations == configurations)
        #expect(fixture.view.operations.isEmpty)
    }

    @Test("setHeader and explicit remove retain documented reload side effects")
    func explicitReloads() async {
        let fixture = ReactiveFixture([ReactiveRow(1), ReactiveRow(2)])
        fixture.section.setHeader(ReactiveHeader.self, model: ReactiveHeaderModel())
        fixture.view.layoutIfNeeded()
        #expect(fixture.view.operations.contains("reloadSections"))
        fixture.view.operations.removeAll()
        await withCheckedContinuation { continuation in
            fixture.view.batchCompleted = { continuation.resume() }
            fixture.section.remove(0)
        }
        #expect(fixture.view.operations.contains("reloadItems"))
    }
}
