// MIT License
//
// Copyright (c) 2020 linhey
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#if canImport(UIKit)
import UIKit

public class SKScrollViewDelegateForward: NSObject, UIScrollViewDelegate {
    
    var scrollForwards: [SKScrollViewDelegateForwardProtocol] = []
    var scrollObservers: [SKScrollViewDelegateObserverProtocol] = []
    
}

public extension SKScrollViewDelegateForward {

    func add(scroll item: SKScrollViewDelegateObserverProtocol) {
        scrollObservers.append(item)
    }
    
    func add(scroll item: SKScrollViewDelegateForwardProtocol) {
        scrollForwards.append(item)
    }
    
    /// 对 2.1.0 以下版本兼容处理
    @available(*, deprecated, message: "调整为 SKScrollViewDelegateObserverProtocol")
    func add(_ item: UIScrollViewDelegate) {
        add(SKScrollViewDelegateObserverBox.init(box: .init(item)))
    }
    
    func add(_ item: SKScrollViewDelegateObserverProtocol) {
        add(scroll: item)
    }
    
    func add(_ item: SKScrollViewDelegateForwardProtocol) {
        add(scroll: item)
    }
    
    func find<T>(`default`: T, _ task: (_ item: SKScrollViewDelegateForwardProtocol) -> SKHandleResult<T>) -> T {
        for item in scrollForwards.reversed() {
            let result = task(item)
            switch result {
            case .handle(let value):
                return value
            case .next:
                break
            }
        }
        return `default`
    }
    
    func find(_ task: (_ item: SKScrollViewDelegateForwardProtocol) -> SKHandleResult<Void>) -> Void {
        return find(default: (), task)
    }
    
    func observe(_ task: (_ item: SKScrollViewDelegateObserverProtocol) -> Void) {
        scrollObservers.forEach(task)
    }
    
}

// MARK: - scrollViewDelegate

public extension SKScrollViewDelegateForward {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let value: Void = find { $0.scrollViewDidScroll(scrollView) }
        observe { item in
            item.scrollViewDidScroll(scrollView, value: value)
        }
        return value
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let value: Void = find { $0.scrollViewDidZoom(scrollView) }
        observe { item in
            item.scrollViewDidZoom(scrollView, value: value)
        }
        return value
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let value: Void = find { $0.scrollViewWillBeginDragging(scrollView) }
        observe { item in
            item.scrollViewWillBeginDragging(scrollView, value: value)
        }
        return value
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let value: Void = find { $0.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset) }
        observe { item in
            item.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset, value: value)
        }
        return value
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let value: Void = find { $0.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate) }
        observe { item in
            item.scrollViewDidEndDragging(scrollView, willDecelerate: decelerate, value: value)
        }
        return value
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let value: Void = find { $0.scrollViewWillBeginDecelerating(scrollView) }
        observe { item in
            item.scrollViewWillBeginDecelerating(scrollView, value: value)
        }
        return value
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let value: Void = find { $0.scrollViewDidEndDecelerating(scrollView) }
        observe { item in
            item.scrollViewDidEndDecelerating(scrollView, value: value)
        }
        return value
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let value: Void = find { $0.scrollViewDidEndScrollingAnimation(scrollView) }
        observe { item in
            item.scrollViewDidEndScrollingAnimation(scrollView, value: value)
        }
        return value
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        let value = find(default: nil) { $0.viewForZooming(in: scrollView) }
        observe { item in
            item.viewForZooming(in: scrollView, value: value)
        }
        return value
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        let value: Void = find { $0.scrollViewWillBeginZooming(scrollView, with: view) }
        observe { item in
            item.scrollViewWillBeginZooming(scrollView, with: view, value: value)
        }
        return value
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        let value: Void = find { $0.scrollViewDidEndZooming(scrollView, with: view, atScale: scale) }
        observe { item in
            item.scrollViewDidEndZooming(scrollView, with: view, atScale: scale, value: value)
        }
        return value
    }
    
    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        let value = find(default: true) { $0.scrollViewShouldScrollToTop(scrollView) }
        observe { item in
            item.scrollViewShouldScrollToTop(scrollView, value: value)
        }
        return value
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        let value: Void = find { $0.scrollViewDidScrollToTop(scrollView) }
        observe { item in
            item.scrollViewDidScrollToTop(scrollView, value: value)
        }
        return value
    }
    
    @available(iOS 11.0, *)
    func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {
        let value: Void = find { $0.scrollViewDidChangeAdjustedContentInset(scrollView) }
        observe { item in
            item.scrollViewDidChangeAdjustedContentInset(scrollView, value: value)
        }
        return value
    }
}
#endif
