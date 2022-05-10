//
//  File.swift
//
//
//  Created by linhey on 2022/4/19.
//

import Foundation

open class SectionDataTransform<Model> {
    public var task: (([Model]) -> [Model])?
    
    public init(task: (([Model]) -> [Model])?) {
        self.task = task
    }
}

public class SectionHiddenTransform<Model>: SectionDataTransform<Model> {
    private var list: [Model]?
    private var oldValue: Bool = false
    
    func by(_ block: @escaping () -> Bool) {
        task = { [weak self] list in
            guard let self = self else { return [] }
            let newValue = block()
            let oldValue = self.oldValue
            self.oldValue = newValue
            
            switch (oldValue, newValue) {
            case (true, true):
                /// hidden 期间的数据更新
                self.list = list.isEmpty ? self.list : list
                return []
            case (false, true):
                self.list = list
                return []
            case (false, false):
                return list
            case (true, false):
                let list = self.list
                self.list = nil
                return list ?? []
            }
        }
    }
}

public class SectionTransforms<Cell: SectionConfigurableModelProtocol> {
    public let hidden = SectionHiddenTransform<Cell.Model>(task: nil)
    public let validate = SectionDataTransform<Cell.Model>(task: { $0.filter(Cell.validate) })
    public lazy var all = [self.hidden, self.validate]
}
