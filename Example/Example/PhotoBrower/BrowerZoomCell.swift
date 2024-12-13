import UIKit
import Photos
import PhotosUI
import SectionUI

public protocol BrowerItemModelProtocol {
    var id: String { get }
    var size: CGSize { get }
}

struct BrowerPlaceHolderModel: BrowerItemModelProtocol {
    var id: String
    var size: CGSize = .init(width: 400, height: 400)
}

public protocol BrowerItemViewProtocol: UIView, SKConfigurableModelProtocol where Model == any BrowerItemModelProtocol {
    var view: UIView { get }
}

public extension BrowerItemViewProtocol {
    var view: UIView { self }
}

open class BrowerZoomCell<ItemView: BrowerItemViewProtocol>: UICollectionViewCell, UIScrollViewDelegate, SKLoadViewProtocol, SKConfigurableView {
    
    class Gestures {
        let singleTap: ((_ model: Model) -> Void)?
        let longPress: ((_ model: Model) -> Void)?
        init(singleTap: ((_: Model) -> Void)? = nil,
             longPress: ((_: Model) -> Void)? = nil) {
            self.singleTap = singleTap
            self.longPress = longPress
        }
    }
    
    public struct Model {
        let item: ItemView.Model
        let gestures: Gestures
    }
    
    public static func preferredSize(limit size: CGSize, model: Model?) -> CGSize {
        size
    }
    
    public var item: ItemView.Model { model?.item ?? BrowerPlaceHolderModel(id: "") }
    public var model: Model?
    
    public func config(_ model: Model) {
        self.model = model
        self.previewView.config(model.item)
        setupScrollViewContentSize()
    }
    
    public lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.delegate = self
        view.showsHorizontalScrollIndicator = false
        view.showsVerticalScrollIndicator = false
        view.bouncesZoom = true
        view.minimumZoomScale = 1
        view.isMultipleTouchEnabled = true
        view.scrollsToTop = false
        view.delaysContentTouches = false
        view.canCancelContentTouches = true
        view.alwaysBounceVertical = false
        view.autoresizingMask = UIView.AutoresizingMask(arrayLiteral: .flexibleWidth, .flexibleHeight)
        view.contentInsetAdjustmentBehavior = .never
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(singleTap(tap:)))
        view.addGestureRecognizer(singleTap)
        let doubleTap = UITapGestureRecognizer.init(target: self, action: #selector(doubleTap(tap:)))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        singleTap.require(toFail: doubleTap)
        view.addGestureRecognizer(doubleTap)
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPressClick(longPress:)))
        view.addGestureRecognizer(longPress)
        return view
    }()
    
    var previewView: ItemView
    var scrollContentView: UIView { previewView.view }
    var contentMaximumZoomScale: CGFloat = 0
    
    override init(frame: CGRect) {
        previewView = ItemView()
        super.init(frame: frame)
        scrollView.addSubview(scrollContentView)
        contentView.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(10)
            make.top.bottom.equalToSuperview()
        }
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var isPad: Bool {
        if #available(iOS 14.0, *), ProcessInfo.processInfo.isiOSAppOnMac {
            return true
        }
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    var isPortrait: Bool {
        if #available(iOS 14.0, *), ProcessInfo.processInfo.isiOSAppOnMac {
            return true
        }
        if isPad {
            return true
        }
        let statusBarOrientation = UIApplication.shared.windows.first(where: \.isKeyWindow)?.windowScene?.interfaceOrientation ?? .unknown
        if  statusBarOrientation == .landscapeLeft || statusBarOrientation == .landscapeRight {
            return false
        }
        return true
    }
    
    func checkContentSize() {
        if !isPortrait {
            return
        }
        if scrollContentView.frame.width / scrollView.zoomScale != contentView.frame.width {
            if isPad  {
                setupLandscapeContentSize()
            }else {
                setupPortraitContentSize()
            }
        }
    }
    func setupScrollViewContentSize() {
        scrollView.zoomScale = 1
        if isPortrait, !isPad {
            setupPortraitContentSize()
        }else {
            setupLandscapeContentSize()
        }
    }
    
    func setupPortraitContentSize() {
        let width  = contentView.frame.width
        let height = contentView.frame.height
        let size   = contentView.frame.size
        
        let aspectRatio = contentView.frame.width / item.size.width
        let contentWidth = width
        let contentHeight = item.size.height * aspectRatio
        if contentWidth < contentHeight {
            if contentMaximumZoomScale >= 1 {
                scrollView.maximumZoomScale = contentMaximumZoomScale
            }else {
                scrollView.maximumZoomScale = width * 2.5 / contentWidth
            }
        }else {
            if contentMaximumZoomScale >= 1 {
                scrollView.maximumZoomScale = contentMaximumZoomScale
            }else {
                scrollView.maximumZoomScale = height * 2.5 / contentHeight
            }
        }
        scrollContentView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight)
        if contentHeight < height {
            scrollView.contentSize = size
            scrollContentView.center = CGPoint(x: width * 0.5, y: height * 0.5)
        }else {
            scrollView.contentSize = CGSize(width: contentWidth, height: contentHeight)
        }
    }
    
    func setupLandscapeContentSize() {
        let width  = contentView.frame.width
        let height = contentView.frame.height
        let size   = contentView.frame.size
        
        let aspectRatio = height / item.size.height
        var contentWidth = item.size.width * aspectRatio
        var contentHeight = height
        if contentWidth > width {
            contentHeight = width / contentWidth * contentHeight
            contentWidth = width
            if contentMaximumZoomScale >= 1 {
                scrollView.maximumZoomScale = contentMaximumZoomScale
            }else {
                scrollView.maximumZoomScale = height / contentHeight + 0.5
            }
            scrollContentView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight)
            scrollView.contentSize = scrollContentView.frame.size
        }else {
            if contentMaximumZoomScale >= 1 {
                scrollView.maximumZoomScale = contentMaximumZoomScale
            }else {
                scrollView.maximumZoomScale = width / contentWidth + 0.5
            }
            scrollContentView.frame = CGRect(x: 0, y: 0, width: contentWidth, height: contentHeight)
            scrollView.contentSize = size
        }
        scrollContentView.center = CGPoint(x: width * 0.5, y: height * 0.5)
    }

    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scrollContentView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.frame.width > scrollView.contentSize.width) ?
        (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0.0
        let offsetY = (scrollView.frame.height > scrollView.contentSize.height) ?
        (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0.0
        scrollContentView.center = CGPoint(
            x: scrollView.contentSize.width * 0.5 + offsetX,
            y: scrollView.contentSize.height * 0.5 + offsetY
        )
    }
    
    @objc func singleTap(tap: UITapGestureRecognizer) {
        guard let model = model else { return }
        model.gestures.singleTap?(model)
    }
    
    @objc func doubleTap(tap: UITapGestureRecognizer) {
        let width  = contentView.frame.width
        let height = contentView.frame.height
        
        if scrollView.zoomScale > 1 {
            scrollView.setZoomScale(1, animated: true)
        }else {
            let touchPoint = tap.location(in: scrollContentView)
            let maximumZoomScale = scrollView.maximumZoomScale
            let zoomWidth = width / maximumZoomScale
            let zoomHeight = height / maximumZoomScale
            scrollView.zoom(
                to: CGRect(
                    x: touchPoint.x - zoomWidth / 2,
                    y: touchPoint.y - zoomHeight / 2,
                    width: zoomWidth,
                    height: zoomHeight
                ),
                animated: true
            )
        }
    }
    
    @objc func longPressClick(longPress: UILongPressGestureRecognizer) {
        if longPress.state == .began {
            guard let model = model else { return }
            model.gestures.longPress?(model)
        }
    }
    
}
