//
//  File.swift
//  
//
//  Created by linhey on 2022/8/13.
//

#if canImport(UIKit)
import UIKit
import Combine

public class SKCSectionInjection {
    public typealias ActionTask    = (_ injection: SKCSectionInjection,  _ action: Action) -> Void
    public typealias ActionConvert = (_ action: Action) -> Action

    public struct Configuration {
        /// 转换类型
        /// 将 reloadSection 操作替换为 reloadData 操作:
        //        SKCSectionInjection.configuration.mapAction = { action in
        //            if action == .reload {
        //                return .reload
        //            }
        //            return action
        //        }
       public var converts: [ActionConvert] = []
        
       public mutating func setMapAction(_ block: @escaping ActionConvert) {
            self.converts = [block]
        }
    }

    public enum ActionKind: Hashable {
        case reload
        case delete
        case reloadData
        case insertItems
        case deleteItems
        case reloadItems
    }
    
    public enum Action: Hashable {
        case reload
        case delete
        case reloadData
        case insertItems([Int])
        case deleteItems([Int])
        case reloadItems([Int])
        
        var kind: ActionKind {
            switch self {
            case .reload:
                return .reload
            case .delete:
                return .delete
            case .reloadData:
                return .reloadData
            case .insertItems:
                return .insertItems
            case .deleteItems:
                return .deleteItems
            case .reloadItems:
                return .reloadItems
            }
        }
    }
    
    class SectionViewProvider {
        
        weak var sectionView: UICollectionView?
        weak var manager: SKCManager?

        init(_ sectionView: UICollectionView?, manager: SKCManager?) {
            self.sectionView = sectionView
            self.manager = manager
        }
    }
    
    public static var configuration = Configuration()
    public var configuration = SKCSectionInjection.configuration
    public internal(set) var index: Int
    public var sectionView: UICollectionView? { sectionViewProvider.sectionView }
    public var manager: SKCManager? { sectionViewProvider.manager }

    var sectionViewProvider: SectionViewProvider
    private var events: [ActionKind: ActionTask] = [:]
    
    init(index: Int, sectionView: SectionViewProvider) {
        self.sectionViewProvider = sectionView
        self.index = index
        setupActions()
    }
    
    func setupActions() {
        add(kind: .reloadData, event: { (injection, action) in
            injection.sectionView?.reloadData()
        })
        add(kind: .reload, event: { (injection, action) in
            injection.sectionView?.reloadSections(IndexSet(integer: injection.index))
        })
        add(kind: .delete, event: { (injection, action) in
            injection.sectionView?.deleteSections(IndexSet(integer: injection.index))
        })
        add(kind: .reloadItems, event: { injection, action in
            switch action {
            case .reloadItems(let idx):
                injection.sectionView?.reloadItems(at: injection.indexPath(from: idx))
            default:
                break
            }
        })
        add(kind: .deleteItems) { injection, action in
            switch action {
            case .deleteItems(let idx):
                injection.sectionView?.deleteItems(at: injection.indexPath(from: idx))
            default:
                break
            }
        }
        add(kind: .insertItems) { injection, action in
            switch action {
            case .insertItems(let idx):
                injection.sectionView?.insertItems(at: injection.indexPath(from: idx))
            default:
                break
            }
        }
    }
    
}

public extension SKCSectionInjection {
    
    func pick(_ updates: () -> Void, completion: ((_ flag: Bool) -> Void)? = nil) {
        sectionView?.performBatchUpdates(updates, completion: completion)
    }
    
    func task(_ action: Action) {
        let convert = configuration.converts.reduce(into: action) { result, convert in
            result = convert(result)
        }
        events[convert.kind]?(self, convert)
    }
    
    func delete() {
        task(.delete)
    }
    
    func reload() {
        task(.reload)
    }
    
    func reloadData() {
        task(.reloadData)
    }
    
    func insert(cell rows: [Int]) {
        task(.insertItems(rows))
    }

    func delete(cell rows: [Int]) {
        task(.deleteItems(rows))
    }
    
    func reload(cell rows: [Int]) {
        guard !rows.isEmpty else {
            return
        }
        task(.reloadItems(rows))
    }
    
    @discardableResult
    func add(kind: ActionKind, event: @escaping ActionTask) -> Self {
        self.events[kind] = event
        return self
    }
    
    /**
     该方法用于根据给定的value返回一个IndexPath对象。如果sectionInjection为nil，则会触发断言失败，并返回一个item为value，section为0的IndexPath对象。否则，返回一个item为value，section为sectionInjection的index的IndexPath对象。
     */
    func indexPath(from value: Int) -> IndexPath {
        return .init(item: value, section: index)
    }
    
    func indexPath(from value: [Int]) -> [IndexPath] {
        return value.map(indexPath(from:))
    }
    
}

#endif
