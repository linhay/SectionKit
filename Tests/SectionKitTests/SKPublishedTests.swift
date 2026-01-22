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

@Suite("SKPublished")
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
        try await Task.sleep(for: .seconds(2))
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

    // MARK: - Publisher Extension Tests

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
    @Test("Events are delivered on main thread")
    func mainThreadDelivery() async throws {
        var cancellables = Set<AnyCancellable>()

        let pub = SKPublishedValue(wrappedValue: 0, kind: .currentValue)

        let isMainThreadRecorder = ActorRecorder<Bool>()
        await MainActor.run {
            pub.sink { _ in
                Task { await isMainThreadRecorder.append(Thread.isMainThread) }
            }.store(in: &cancellables)
        }

        // Send from background thread
        await Task.detached {
            pub.send(1)
        }.value

        let values = try await isMainThreadRecorder.waitValues(count: 2, timeout: 1.0)
        // All values should be delivered on main thread
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
        let cancellable = (voidPublisher as! AnyPublisher<Void, Never>)
            .sink { _ in receivedCount += 1 }

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
