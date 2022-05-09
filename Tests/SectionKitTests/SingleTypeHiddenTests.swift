import XCTest
import Combine
import SectionKit

final class SingleTypeHiddenTests: XCTestCase {
    
    func testHiddenByValue() throws {
        XCTAssert(SectionVoidCell.singleTypeWrapper(count: 1).hidden(true).models.count == 0)
        XCTAssert(SectionVoidCell.singleTypeWrapper(count: 1).hidden(true).hidden(false).models.count == 1)
    }
    
    func testHiddenByBlock() throws {
        var flag = false
        let section = SectionVoidCell.singleTypeWrapper(count: 1).hidden(by: { flag })
        XCTAssert(section.models.count == 1)
        flag = true
        section.reload()
        XCTAssert(section.models.count == 0)
        flag = false
        section.reload()
        XCTAssert(section.models.count == 1)
    }
    
    func testHiddenByPublisher() throws {
        let publisher = PassthroughSubject<Bool, Never>()
        let section = SectionVoidCell.singleTypeWrapper(count: 1)
        section.hidden(by: publisher.eraseToAnyPublisher())
        XCTAssert(section.models.count == 1)
        publisher.send(true)
        XCTAssert(section.models.count == 0)
        publisher.send(false)
        XCTAssert(section.models.count == 1)
        publisher.send(false)
        XCTAssert(section.models.count == 1)
    }
    
    func testHiddenByKeyPath() throws {
        class Flag {
            var value = false
        }
        
        let flag = Flag()
        let section = SectionVoidCell.singleTypeWrapper(count: 1)
        section.hidden(by: flag, \.value)
        XCTAssert(section.models.count == 1)
        flag.value = true
        section.reload()
        XCTAssert(section.models.count == 0)
        flag.value = false
        section.reload()
        XCTAssert(section.models.count == 1)
    }
    
}
