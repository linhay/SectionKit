//
//  File.swift
//  
//
//  Created by linhey on 2023/7/20.
//

import Foundation

public extension SKCSingleTypeSection {
    
    struct ModelDisplayedContext {
        public let model: Model
        public let row: Int
    }
    
    /// 在数据第 n 次曝光时触发回调
    /// - Parameters:
    ///   - count: 第 n 次曝光
    ///   - observe: 回调
    /// - Returns: self
    @discardableResult
    func model(displayedAt time: Int,
               observe: @escaping (_ context: ModelDisplayedContext) -> Void) -> Self {
        displayedTimes.trigger { [weak self] (row, count) in
            guard let self = self,
                  time == count,
                  self.models.indices.contains(row) else {
                return
            }
            observe(.init(model: models[row], row: row))
        }
        return self
    }
    
}
