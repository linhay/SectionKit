//
//  File.swift
//
//
//  Created by linhey on 2022/9/14.
//

import Combine

public class SKCPrefetch {

    public enum LoadMoreState: Equatable {
        case idle
        case loading
        case noMore
        case failed
    }

    let prefetch = PassthroughSubject<[Int], Never>()
    let cancelPrefetching = PassthroughSubject<[Int], Never>()
    private let displayedRow = PassthroughSubject<Int, Never>()
    public var loadMoreThreshold: Int = 0
    public private(set) var loadMoreState: LoadMoreState = .idle
    let count: () -> Int

    init(count: @escaping () -> Int) {
        self.count = count
    }

    /// Records a row that is about to become visible.
    ///
    /// This is intentionally separate from `prefetch`: UIKit may skip
    /// prefetch callbacks, while a displayed cell is a visibility signal.
    func display(at row: Int) {
        displayedRow.send(row)
    }

}

public extension SKCPrefetch {

    @discardableResult
    func setLoadMoreState(_ state: LoadMoreState) -> Self {
        loadMoreState = state
        return self
    }

    @discardableResult
    func finishLoadMore(hasMore: Bool = true) -> Self {
        setLoadMoreState(hasMore ? .idle : .noMore)
    }

    @discardableResult
    func failLoadMore() -> Self {
        setLoadMoreState(.failed)
    }

    /// Emits when a prefetched row reaches the current load-more boundary.
    ///
    /// UIKit may skip prefetch callbacks, so this publisher is best effort and
    /// must not be used as the only correctness signal for pagination.
    var loadMorePublisher: AnyPublisher<Void, Never> {
        prefetch
            .compactMap({ $0.max() })
            .filter { [weak self] row in self?.isLoadMoreBoundary(row) == true }
            .map({ _ in })
            .eraseToAnyPublisher()

    }

    /// Emits when a visible row reaches the current load-more boundary.
    ///
    /// Unlike `loadMorePublisher`, this signal is driven by the section's
    /// `willDisplay` lifecycle and is suitable for correctness-critical
    /// pagination.
    var loadMoreOnDisplayPublisher: AnyPublisher<Void, Never> {
        displayedRow
            .filter { [weak self] row in self?.isLoadMoreBoundary(row) == true }
            .map({ _ in })
            .eraseToAnyPublisher()
    }

    /// 带状态门闩的加载更多, 触发后进入 loading, 调用 finishLoadMore/failLoadMore 后才会再次触发
    var statefulLoadMorePublisher: AnyPublisher<Void, Never> {
        statefulLoadMorePublisher(from: loadMorePublisher)
    }

    /// 基于可见生命周期并带状态门闩的加载更多。
    ///
    /// 触发后进入 `loading`，调用 `finishLoadMore` 或 `failLoadMore` 后才会再次触发。
    var statefulLoadMoreOnDisplayPublisher: AnyPublisher<Void, Never> {
        statefulLoadMorePublisher(from: loadMoreOnDisplayPublisher)
    }

    private func statefulLoadMorePublisher(from publisher: AnyPublisher<Void, Never>) -> AnyPublisher<Void, Never> {
        publisher
            .filter { [weak self] in
                guard let self = self else { return false }
                return self.loadMoreState == .idle || self.loadMoreState == .failed
            }
            .handleEvents(receiveOutput: { [weak self] in
                self?.loadMoreState = .loading
            })
            .eraseToAnyPublisher()
    }

    private func isLoadMoreBoundary(_ row: Int) -> Bool {
        let itemCount = count()
        guard itemCount > 0 else { return false }
        return row >= itemCount - 1 - max(0, loadMoreThreshold)
    }

    /// 预测将加载的 rows
    var prefetchPublisher: AnyPublisher<[Int], Never> { prefetch.eraseToAnyPublisher() }
    /// 取消加载
    var cancelPrefetchingPublisher: AnyPublisher<[Int], Never> { cancelPrefetching.eraseToAnyPublisher() }

}
