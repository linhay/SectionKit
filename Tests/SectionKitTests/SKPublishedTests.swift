//
//  SKPublishedTests.swift
//  SectionKit
//
//  Created by Sisyphus on 2026/01/22.
//

import Combine
import Foundation
import SectionKit
import Testing

@Suite("SKPublished", .serialized)
class SKPublishedTests {

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test(
        "Thread 1: Simultaneous accesses to 0x139675078, but modification requires exclusive access"
    )
    func modification_requires_exclusive_access() async throws {
        class VMItem {}

        class VM {
            @SKPublished var items: [VMItem] = []
        }

        var cancellables = Set<AnyCancellable>()
        let vm = VM()
        vm.$items
            .dropFirst()
            .sink { _ in
                print(vm.items)
            }.store(in: &cancellables)
        vm.items = [.init()]
        try await Task.sleep(for: .milliseconds(100))
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("passThrough + bind(): emits current snapshot then future changes")
    func passThrough_bind_emitsSnapshotAndChanges() async throws {
        var cancellables = Set<AnyCancellable>()
        @SKPublished(kind: .passThrough) var value: Int = 0

        let recorder = ActorRecorder<Int>()
        await MainActor.run {
            $value.bind { newValue in
                Task { await recorder.append(newValue) }
            }.store(in: &cancellables)
            value = 1
            value = 2
        }

        let values = try await recorder.waitValues(count: 3, timeout: 1.0)
        #expect(values == [0, 1, 2])
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("currentValue kind replays latest value to new subscribers")
    func currentValue_replaysLatest() async throws {
        var cancellables = Set<AnyCancellable>()

        let pub = SKPublishedValue(wrappedValue: 0, kind: .currentValue)
        pub.send(1)
        pub.send(2)

        let recorder = ActorRecorder<Int>()
        await MainActor.run {
            pub.sink { value in
                Task { await recorder.append(value) }
            }.store(in: &cancellables)
        }

        let values = try await recorder.waitValues(count: 1, timeout: 1.0)
        // sink() should receive the latest (2) from CurrentValueSubject.
        #expect(values.first == 2)
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("currentValue direct value setter updates value immediately and emits on main")
    func currentValue_valueSetterUpdatesImmediatelyAndEmitsOnMain() async throws {
        let values = ActorRecorder<Int>()
        let recorder = ActorRecorder<Bool>()
        let pub = SKPublishedValue(wrappedValue: 0, kind: .currentValue)
        let cancellable = pub.sink {
            let value = $0
            let isMainThread = Thread.isMainThread
            Task {
                await values.append(value)
                await recorder.append(isMainThread)
            }
        }

        pub.value = 1
        #expect(pub.value == 1)

        #expect(try await values.waitValues(count: 2, timeout: 1.0) == [0, 1])
        _ = try await recorder.waitValues(count: 2, timeout: 1.0)
        #expect(await recorder.values.allSatisfy { $0 })
        cancellable.cancel()
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("passThrough kind does not replay past values to new subscribers")
    func passThrough_doesNotReplay() async throws {
        var cancellables = Set<AnyCancellable>()

        let pub = SKPublishedValue(wrappedValue: 0, kind: .passThrough)
        pub.send(1)
        pub.send(2)

        let recorder = ActorRecorder<Int>()
        await MainActor.run {
            pub.sink { value in
                Task { await recorder.append(value) }
            }.store(in: &cancellables)
        }

        // No new send => should not receive historical values.
        try await Task.sleep(for: .milliseconds(80))
        #expect(await recorder.values.isEmpty)

        pub.send(3)
        let values = try await recorder.waitValues(count: 1, timeout: 1.0)
        #expect(values == [3])
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("passThrough direct value setter updates value immediately and emits on main")
    func passThrough_valueSetterUpdatesImmediatelyAndEmitsOnMain() async throws {
        let values = ActorRecorder<Int>()
        let recorder = ActorRecorder<Bool>()
        let pub = SKPublishedValue(wrappedValue: 0, kind: .passThrough)
        let cancellable = pub.sink {
            let value = $0
            let isMainThread = Thread.isMainThread
            Task {
                await values.append(value)
                await recorder.append(isMainThread)
            }
        }

        pub.value = 1
        #expect(pub.value == 1)

        #expect(try await values.waitValues(count: 1, timeout: 1.0) == [1])
        _ = try await recorder.waitValues(count: 1, timeout: 1.0)
        #expect(await recorder.values.allSatisfy { $0 })
        cancellable.cancel()
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("cancelled subscription receives no later values")
    func subscriptionCancelStopsEvents() async throws {
        let values = ActorRecorder<Int>()
        let pub = SKPublishedValue(wrappedValue: 0, kind: .passThrough)
        let cancellable = pub.sink { value in
            Task { await values.append(value) }
        }

        pub.send(1)
        #expect(try await values.waitValues(count: 1, timeout: 1.0) == [1])
        cancellable.cancel()
        pub.send(2)
        try await Task.sleep(for: .milliseconds(50))

        #expect(await values.values == [1])
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("removeDuplicates transform suppresses duplicates")
    func transform_removeDuplicates() async throws {
        var cancellables = Set<AnyCancellable>()

        let pub = SKPublishedValue(
            wrappedValue: 0,
            kind: .currentValue,
            transform: [.removeDuplicates()]
        )

        let recorder = ActorRecorder<Int>()
        await MainActor.run {
            pub.sink { value in
                Task { await recorder.append(value) }
            }.store(in: &cancellables)
        }

        pub.send(0)
        pub.send(0)
        pub.send(1)
        pub.send(1)
        pub.send(2)

        let values = try await recorder.waitValues(count: 3, timeout: 1.0)
        // Initial currentValue + unique changes only.
        #expect(values == [0, 1, 2])
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("re-entrant access inside subscriber (read + write) does not trap exclusivity")
    func reentrant_readWrite_doesNotTrap() async throws {
        final class Value {
            let value: Int
            init(_ value: Int) { self.value = value }
        }

        var cancellables = Set<AnyCancellable>()
        @SKPublished var test: Value = .init(0)

        let recorder = ActorRecorder<Int>()
        let didWriteOnce = ManagedAtomicFlag()

        await MainActor.run {
            $test.sink { _ in
                // This exact pattern used to trigger Swift exclusivity trap:
                //   - setter enters didSet
                //   - didSet sends to subscribers
                //   - subscriber reads `test` while setter still holds exclusive access
                Task { await recorder.append(test.value) }

                if didWriteOnce.trySetTrue() {
                    test = .init(2)
                }
            }.store(in: &cancellables)

            test = .init(1)
        }

        // If the process didn't crash, and we observed values, we're good.
        let values = try await recorder.waitValues(count: 1, timeout: 1.0)
        #expect(values.contains(1) || values.contains(2))
    }

    // MARK: - Transform Tests

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("dropFirst transform skips initial values")
    func transform_dropFirst() async throws {
        var cancellables = Set<AnyCancellable>()

        let pub = SKPublishedValue(
            wrappedValue: 0,
            kind: .currentValue,
            transform: [.dropFirst(count: 2)]
        )

        let recorder = ActorRecorder<Int>()
        await MainActor.run {
            pub.sink { value in
                Task { await recorder.append(value) }
            }.store(in: &cancellables)
        }

        pub.send(1)
        pub.send(2)
        pub.send(3)

        let values = try await recorder.waitValues(count: 2, timeout: 1.0)
        // Should skip 0, 1 and receive 2, 3
        #expect(values == [2, 3])
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("filter transform only passes matching values")
    func transform_filter() async throws {
        var cancellables = Set<AnyCancellable>()

        let pub = SKPublishedValue(
            wrappedValue: 0,
            kind: .passThrough,
            transform: [.filter { $0 % 2 == 0 }]
        )

        let recorder = ActorRecorder<Int>()
        await MainActor.run {
            pub.sink { value in
                Task { await recorder.append(value) }
            }.store(in: &cancellables)
        }

        pub.send(1)
        pub.send(2)
        pub.send(3)
        pub.send(4)
        pub.send(5)

        let values = try await recorder.waitValues(count: 2, timeout: 1.0)
        #expect(values == [2, 4])
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("drop while transform skips prefix only")
    func transform_dropWhile() async throws {
        var cancellables = Set<AnyCancellable>()

        let pub = SKPublishedValue(
            wrappedValue: 0,
            kind: .currentValue,
            transform: [.drop(while: { $0 < 3 })]
        )

        let recorder = ActorRecorder<Int>()
        await MainActor.run {
            pub.sink { value in
                Task { await recorder.append(value) }
            }.store(in: &cancellables)
        }

        pub.send(1)
        pub.send(2)
        pub.send(3)
        pub.send(1)

        let values = try await recorder.waitValues(count: 2, timeout: 1.0)
        #expect(values == [3, 1])
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("onChanged transform is called with old and new values")
    func transform_onChanged() async throws {
        var cancellables = Set<AnyCancellable>()

        let changesRecorder = ActorRecorder<(Int, Int)>()

        let pub = SKPublishedValue(
            wrappedValue: 0,
            kind: .currentValue,
            transform: [
                .init(onChanged: { old, new in
                    Task { await changesRecorder.append((old, new)) }
                })
            ]
        )

        await MainActor.run {
            pub.sink { _ in }.store(in: &cancellables)
        }

        pub.send(1)
        pub.send(2)

        let changes = try await changesRecorder.waitValues(count: 2, timeout: 1.0)
        #expect(changes.count == 2)
        #expect(changes[0].0 == 0 && changes[0].1 == 1)
        #expect(changes[1].0 == 1 && changes[1].1 == 2)
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("Equatable onChanged transform suppresses duplicate values")
    func transform_onChangedEquatableSkipsDuplicates() async throws {
        let recorder = ActorRecorder<Int>()
        let pub = SKPublishedValue(
            wrappedValue: 0,
            kind: .currentValue,
            transform: .onChanged { value in
                Task { await recorder.append(value) }
            }
        )

        pub.send(0)
        pub.send(1)
        pub.send(1)
        pub.send(2)

        let values = try await recorder.waitValues(count: 2, timeout: 1.0)
        #expect(values == [1, 2])
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("removeDuplicates with keyPath only compares specified property")
    func transform_removeDuplicates_keyPath() async throws {
        struct Item: Sendable {
            let id: Int
            let name: String
        }

        var cancellables = Set<AnyCancellable>()

        let pub = SKPublishedValue(
            wrappedValue: Item(id: 0, name: "zero"),
            kind: .currentValue,
            transform: [.removeDuplicates(by: \.id)]
        )

        let recorder = ActorRecorder<Int>()
        await MainActor.run {
            pub.sink { value in
                Task { await recorder.append(value.id) }
            }.store(in: &cancellables)
        }

        pub.send(Item(id: 0, name: "zero-updated"))  // Same id, should be filtered
        pub.send(Item(id: 1, name: "one"))
        pub.send(Item(id: 1, name: "one-updated"))  // Same id, should be filtered
        pub.send(Item(id: 2, name: "two"))

        let values = try await recorder.waitValues(count: 3, timeout: 1.0)
        #expect(values == [0, 1, 2])
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("mapPublisher transform supports custom pipelines")
    func transform_mapPublisherCustomPipeline() async throws {
        var cancellables = Set<AnyCancellable>()
        let pub = SKPublishedValue(
            wrappedValue: 0,
            kind: .passThrough,
            transform: .mapPublisher { $0.map { $0 * 10 } }
        )

        let recorder = ActorRecorder<Int>()
        await MainActor.run {
            pub.sink { value in
                Task { await recorder.append(value) }
            }.store(in: &cancellables)
        }

        pub.send(1)
        pub.send(2)

        let values = try await recorder.waitValues(count: 2, timeout: 1.0)
        #expect(values == [10, 20])
    }

    // MARK: - PropertyWrapper Tests

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("SKPublished property wrapper syncs wrappedValue and projectedValue")
    func propertyWrapper_syncValues() async throws {
        @SKPublished var counter: Int = 0

        #expect(counter == 0)
        #expect($counter.value == 0)

        counter = 5
        #expect(counter == 5)
        #expect($counter.value == 5)

        $counter.send(10)
        #expect(counter == 10)
        #expect($counter.value == 10)
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("SKPublished Optional init defaults to nil")
    func propertyWrapper_optionalInit() async throws {
        @SKPublished var optionalValue: String?

        #expect(optionalValue == nil)

        optionalValue = "hello"
        #expect(optionalValue == "hello")

        optionalValue = nil
        #expect(optionalValue == nil)
    }

    @MainActor
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("SKPublished wrappedValue defers publisher delivery until setter returns")
    func propertyWrapper_defersPublisherDelivery() async throws {
        var cancellables = Set<AnyCancellable>()
        @SKPublished var value: Int = 0

        var values: [Int] = []
        $value.sink { values.append($0) }.store(in: &cancellables)
        try await Task.sleep(for: .milliseconds(50))
        #expect(values == [0])

        value = 1
        #expect(value == 1)
        #expect(values == [0])

        try await Task.sleep(for: .milliseconds(50))
        #expect(values == [0, 1])
    }

    @MainActor
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("SKPublished currentValue replays latest value after immediate subscription")
    func propertyWrapper_currentValueImmediateSubscriptionReplaysLatestOnce() async throws {
        var cancellables = Set<AnyCancellable>()
        @SKPublished var value: Int = 0

        value = 1

        var values: [Int] = []
        $value.anyPublisher.sink { values.append($0) }.store(in: &cancellables)

        try await Task.sleep(for: .milliseconds(50))
        #expect(values == [1])

        try await Task.sleep(for: .milliseconds(50))
        #expect(values == [1])
    }

    @MainActor
    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("SKPublished passThrough wrapper does not replay past async changes")
    func propertyWrapper_passThroughDoesNotReplayPastChanges() async throws {
        var cancellables = Set<AnyCancellable>()
        @SKPublished(kind: .passThrough) var value: Int = 0

        value = 1
        try await Task.sleep(for: .milliseconds(50))

        var values: [Int] = []
        $value.sink { values.append($0) }.store(in: &cancellables)
        #expect(values.isEmpty)

        value = 2
        try await Task.sleep(for: .milliseconds(50))
        #expect(values == [2])
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("SKPublished wrapper delivers changes on main thread")
    func propertyWrapper_deliversChangesOnMainThread() async throws {
        final class VM {
            @SKPublished var value = 0
        }

        let vm = VM()
        var cancellables = Set<AnyCancellable>()
        let recorder = ActorRecorder<Bool>()
        await MainActor.run {
            vm.$value.sink { _ in
                let isMainThread = Thread.isMainThread
                Task { await recorder.append(isMainThread) }
            }.store(in: &cancellables)
        }

        await Task.detached {
            vm.value = 1
        }.value

        let values = try await recorder.waitValues(count: 2, timeout: 1.0)
        #expect(values.allSatisfy { $0 })
    }

    // MARK: - Publisher Extension Tests

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("anyPublisher exposes standard Combine publisher")
    func publisher_anyPublisher() async throws {
        let pub = SKPublishedValue(wrappedValue: 0, kind: .currentValue)
        let anyPublisher: AnyPublisher<Int, Never> = pub.anyPublisher
        let values = ActorRecorder<Int>()

        let cancellable = anyPublisher.sink { value in
            Task { await values.append(value) }
        }
        pub.send(1)

        #expect(try await values.waitValues(count: 2, timeout: 1.0) == [0, 1])
        cancellable.cancel()
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("publisher respects downstream demand")
    func publisher_respectsDownstreamDemand() async throws {
        let pub = SKPublishedValue(wrappedValue: 0, kind: .passThrough)
        let subscriber = DemandSubscriber<Int>(initialDemand: .max(1))
        pub.subscribe(subscriber)

        pub.send(1)
        pub.send(2)
        #expect(try await subscriber.waitValues(count: 1, timeout: 1.0) == [1])
        try await Task.sleep(for: .milliseconds(50))
        #expect(subscriber.snapshot == [1])

        subscriber.request(.max(1))
        pub.send(3)
        #expect(try await subscriber.waitValues(count: 2, timeout: 1.0) == [1, 3])
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("assign(onWeak:to:) assigns values and handles object deallocation")
    func publisher_assignOnWeak() async throws {
        class Target {
            var value: Int = 0
        }

        var target: Target? = Target()
        weak var weakTarget = target

        let subject = PassthroughSubject<Int, Never>()
        let cancellable = subject.assign(onWeak: target!, to: \.value)

        subject.send(42)
        try await Task.sleep(for: .milliseconds(50))
        #expect(target?.value == 42)

        // Deallocate target
        target = nil
        #expect(weakTarget == nil)

        // Should not crash when target is nil
        subject.send(100)
        try await Task.sleep(for: .milliseconds(50))

        cancellable.cancel()
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("send() for Void type works correctly")
    func send_voidType() async throws {
        var cancellables = Set<AnyCancellable>()

        let pub = SKPublishedValue(wrappedValue: (), kind: .passThrough)

        let recorder = ActorRecorder<Bool>()
        await MainActor.run {
            pub.sink { _ in
                Task { await recorder.append(true) }
            }.store(in: &cancellables)
        }

        pub.send()
        pub.send()
        pub.send()

        let values = try await recorder.waitValues(count: 3, timeout: 1.0)
        #expect(values.count == 3)
    }

    // MARK: - Thread Safety Tests

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("receiveOnMainQueue transform delivers on main thread")
    func transform_receiveOnMainQueue() async throws {
        var cancellables = Set<AnyCancellable>()

        let pub = SKPublishedValue(
            wrappedValue: 0,
            kind: .passThrough,
            transform: [.receiveOnMainQueue()]
        )

        let isMainThreadRecorder = ActorRecorder<Bool>()
        await MainActor.run {
            pub.sink { _ in
                let isMainThread = Thread.isMainThread
                Task { await isMainThreadRecorder.append(isMainThread) }
            }.store(in: &cancellables)
        }

        await Task.detached {
            pub.send(1)
        }.value

        let values = try await isMainThreadRecorder.waitValues(count: 1, timeout: 1.0)
        #expect(values.allSatisfy { $0 == true })
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("Multiple transforms are applied in order")
    func multipleTransforms_appliedInOrder() async throws {
        var cancellables = Set<AnyCancellable>()

        let pub = SKPublishedValue(
            wrappedValue: 0,
            kind: .currentValue,
            transform: [
                .dropFirst(),  // Skip initial 0
                .filter { $0 > 0 },  // Only positive
                .removeDuplicates(),  // No duplicates
            ]
        )

        let recorder = ActorRecorder<Int>()
        await MainActor.run {
            pub.sink { value in
                Task { await recorder.append(value) }
            }.store(in: &cancellables)
        }

        pub.send(-1)  // Filtered out (not > 0)
        pub.send(1)
        pub.send(1)  // Duplicate, filtered
        pub.send(2)
        pub.send(-2)  // Filtered out
        pub.send(2)  // Duplicate, filtered
        pub.send(3)

        let values = try await recorder.waitValues(count: 3, timeout: 1.0)
        #expect(values == [1, 2, 3])
    }

    @available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
    @Test("ignoreOutputType converts output to Void")
    func publisher_ignoreOutputType() async throws {
        let subject = PassthroughSubject<Int, Never>()
        let voidPublisher = subject.ignoreOutputType()

        var receivedCount = 0
        let cancellable = voidPublisher.sink { _ in receivedCount += 1 }

        subject.send(1)
        subject.send(2)
        subject.send(3)

        try await Task.sleep(for: .milliseconds(50))
        #expect(receivedCount == 3)

        cancellable.cancel()
    }
}

// MARK: - Helpers

/// Simple actor-backed recorder to avoid data races in tests.
actor ActorRecorder<T: Sendable> {
    private(set) var values: [T] = []
    func append(_ value: T) {
        values.append(value)
    }

    var count: Int { values.count }

    /// Wait until at least `target` values are recorded, or until `timeout` seconds elapse.
    ///
    /// Uses `Task.sleep(nanoseconds:)` to stay compatible with iOS 13+.
    func waitValues(count target: Int, timeout: TimeInterval) async throws -> [T] {
        let deadline = Date().addingTimeInterval(timeout)
        while values.count < target {
            if Date() >= deadline {
                break
            }
            try await Task.sleep(nanoseconds: 10_000_000)  // 10ms
        }
        return values
    }
}

/// Tiny atomic-like flag without importing Atomics.
///
/// Tests run single-threaded most of the time; we just need a re-entrancy guard.
final class ManagedAtomicFlag {
    private var value = false
    func trySetTrue() -> Bool {
        if value { return false }
        value = true
        return true
    }
}

final class DemandSubscriber<Input>: Subscriber {

    typealias Failure = Never

    private let lock = NSLock()
    private let initialDemand: Subscribers.Demand
    private var subscription: Subscription?
    private var values: [Input] = []

    init(initialDemand: Subscribers.Demand) {
        self.initialDemand = initialDemand
    }

    var snapshot: [Input] {
        lock.lock()
        defer { lock.unlock() }
        return values
    }

    func receive(subscription: Subscription) {
        self.subscription = subscription
        subscription.request(initialDemand)
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        lock.lock()
        values.append(input)
        lock.unlock()
        return .none
    }

    func receive(completion: Subscribers.Completion<Never>) {}

    func request(_ demand: Subscribers.Demand) {
        subscription?.request(demand)
    }

    func waitValues(count target: Int, timeout: TimeInterval) async throws -> [Input] {
        let deadline = Date().addingTimeInterval(timeout)
        while snapshot.count < target {
            if Date() >= deadline {
                break
            }
            try await Task.sleep(nanoseconds: 10_000_000)
        }
        return snapshot
    }

}
