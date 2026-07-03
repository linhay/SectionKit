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
    private var prefetchCancellable: AnyCancellable?

    var enableLoadMore: Bool = false
    public var loadMoreThreshold: Int = 0
    public private(set) var loadMoreState: LoadMoreState = .idle
    let count: () -> Int

    init(count: @escaping () -> Int) {
        self.count = count
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

    /// 加载更多
    var loadMorePublisher: AnyPublisher<Void, Never> {
        prefetch
            .compactMap({ $0.max() })
            .filter({ [weak self] row in
                guard let self = self else { return false }
                let itemCount = self.count()
                guard itemCount > 0 else { return false }
                return row >= itemCount - 1 - max(0, self.loadMoreThreshold)
            })
            .map({ _ in })
            .eraseToAnyPublisher()

    }

    /// 带状态门闩的加载更多, 触发后进入 loading, 调用 finishLoadMore/failLoadMore 后才会再次触发
    var statefulLoadMorePublisher: AnyPublisher<Void, Never> {
        loadMorePublisher
            .filter { [weak self] in
                guard let self = self else { return false }
                return self.loadMoreState == .idle || self.loadMoreState == .failed
            }
            .handleEvents(receiveOutput: { [weak self] in
                self?.loadMoreState = .loading
            })
            .eraseToAnyPublisher()
    }

    /// 预测将加载的 rows
    var prefetchPublisher: AnyPublisher<[Int], Never> { prefetch.eraseToAnyPublisher() }
    /// 取消加载
    var cancelPrefetchingPublisher: AnyPublisher<[Int], Never> { cancelPrefetching.eraseToAnyPublisher() }

}
