//
//  File.swift
//
//
//  Created by linhey on 2022/4/27.
//

#if canImport(UIKit)
import UIKit
import Combine
import SectionUI
import XCTest

final class wrapperToSingleTypeSectionTests: XCTestCase {
    
    func testHighPerformance() throws {
        /** size 缓存
         "[SectionKit] -> [HighPerformance]" ["cache: id:2665596 size:(375.0, 156.0) limit:(375.0, 680.0)"]
         "[SectionKit] -> [HighPerformance]" ["hit cache: id:48422390 size:(375.0, 156.0) limit:(375.0, 680.0)"]
         */
        let section = SectionVoidCell.wrapperToSingleTypeSection()
            /// 配置缓存ID
            .highPerformanceID { context in
                context.row.description
            }
        
        /** size 缓存共享
         "[SectionKit] -> [HighPerformance]" ["cache: id:2665596 size:(375.0, 156.0) limit:(375.0, 680.0)"]
         "[SectionKit] -> [HighPerformance]" ["cache: id:2665608 size:(375.0, 156.0) limit:(375.0, 680.0)"]
         "[SectionKit] -> [HighPerformance]" ["hit cache: id:48315488 size:(375.0, 156.0) limit:(375.0, 680.0)"]
         "[SectionKit] -> [HighPerformance]" ["hit cache: id:48422390 size:(375.0, 156.0) limit:(375.0, 680.0)"]
         */
        /// 共享缓存
        let highPerformance = SKHighPerformanceStore<String>()
        let section1 = SectionVoidCell.wrapperToSingleTypeSection()
            /// 配置共享缓存
            .setHighPerformance(highPerformance)
            /// 配置缓存ID
            .highPerformanceID { context in
                context.row.description
            }
        let section2 = SectionVoidCell.wrapperToSingleTypeSection()
            /// 配置共享缓存
            .setHighPerformance(highPerformance)
            /// 配置缓存ID
            .highPerformanceID(by: \.row)
    }
    
    func testCount() throws {
        for count in 0 ... Int.random(in: 0 ... 1000) {
            XCTAssert(SectionVoidCell.wrapperToSingleTypeSection(count: count).models.count == count)
        }
    }

    func testEvents() throws {
        let section = SectionVoidCell.wrapperToSingleTypeSection(count: 3)
        let view = SKCollectionView()
        view.frame.size = .init(width: 400, height: 400)
        view.manager.reload(section)

        var returnFlag = -1
        section.onCellAction(.selected, block: { result in
            XCTAssert(returnFlag == result.row)
        })
        section.onCellAction(.willDisplay, block: { result in
            XCTAssert(returnFlag == result.row)
        })
        section.onCellAction(.didEndDisplay, block: { result in
            XCTAssert(returnFlag == result.row)
        })

        for index in [1, 2, 0, -1, 3] {
            returnFlag = index
            section.item(selected: index)
            section.selectItem(at: index)
            section.deselectItem(at: index)
        }
    }
}
#endif
