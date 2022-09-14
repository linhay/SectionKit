//
//  File.swift
//  
//
//  Created by linhey on 2022/9/14.
//

import Combine

public class SKCPrefetch {
    
    let prefetch = PassthroughSubject<[Int], Never>()
    let cancelPrefetching = PassthroughSubject<[Int], Never>()
    
    private let loadMore = PassthroughSubject<Void, Never>()
    private var prefetchCancellable: AnyCancellable?
    
    var enableLoadMore: Bool = false
    let count: () -> Int
    
    init(count: @escaping () -> Int) {
        self.count = count
    }
    
}

public extension SKCPrefetch {
    
    /// 加载更多
    var loadMorePublisher: AnyPublisher<Void, Never> { loadMore.eraseToAnyPublisher() }
    /// 预测将加载的 rows
    var prefetchPublisher: AnyPublisher<[Int], Never> { prefetch.eraseToAnyPublisher() }
    /// 取消加载
    var cancelPrefetchingPublisher: AnyPublisher<[Int], Never> { cancelPrefetching.eraseToAnyPublisher() }
    
}

public extension SKCPrefetch {
    
    /// 是否启用加载更多检测
    /// - Parameter flag: 标志位
    /// 加载更多检测逻辑: 预测 row 值大于当前 row 值
    func enableLoadMore(_ flag: Bool) {
        if flag == false {
            prefetchCancellable = nil
            return
        }
        prefetchCancellable = prefetch
            .compactMap({ $0.max() })
            .sink(receiveValue: { [weak self] row in
                guard let self = self else { return }
                if row > self.count() {
                    self.loadMore.send()
                }
            })
    }
    
}
