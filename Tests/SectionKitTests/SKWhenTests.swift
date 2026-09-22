import SectionKit
import Testing

@Suite("SKWhen")
struct SKWhenTests {

    struct State {
        let isLoaded: Bool
        let count: Int
    }

    @Test("equal and compare evaluate key paths")
    func keyPathPredicates() {
        let state = State(isLoaded: true, count: 3)

        #expect(SKWhen.equal(\State.isLoaded, true).isIncluded(state))
        #expect(SKWhen.compare(\State.count, 2, >).isIncluded(state))
        #expect(!SKWhen.compare(\State.count, 4, >).isIncluded(state))
    }

    @Test("and and or preserve short-circuit behavior")
    func compositionShortCircuits() {
        var hits = 0
        let yes = SKWhen<Int> { _ in true }
        let no = SKWhen<Int> { _ in false }
        let counted = SKWhen<Int> { _ in
            hits += 1
            return true
        }

        #expect(!no.and(counted).isIncluded(0))
        #expect(hits == 0)

        #expect(yes.or(counted).isIncluded(0))
        #expect(hits == 0)

        #expect(yes.and(counted).isIncluded(0))
        #expect(hits == 1)
    }

}
