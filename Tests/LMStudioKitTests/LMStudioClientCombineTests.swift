import Testing
@testable import LMStudioKit
import Foundation
import Combine

// MARK: - LMStudioClient Combine Extension Tests

struct LMStudioClientCombineTests {
    @Test
    func passthroughSubjectBasicBehavior() throws {
        let subject = PassthroughSubject<String, Error>()

        var received: [String] = []
        var completed = false

        let cancellable = subject
            .sink(
                receiveCompletion: { _ in completed = true },
                receiveValue: { received.append($0) }
            )

        subject.send("hello")
        subject.send("world")
        subject.send(completion: .finished)

        #expect(received == ["hello", "world"])
        #expect(completed == true)

        cancellable.cancel()
    }

    @Test
    func passthroughSubjectErrorPropagation() throws {
        let subject = PassthroughSubject<String, Error>()

        var received: [String] = []
        var receivedError = false

        let cancellable = subject
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        receivedError = true
                    }
                },
                receiveValue: { received.append($0) }
            )

        subject.send("before error")
        subject.send(completion: .failure(URLError(.notConnectedToInternet)))

        #expect(received == ["before error"])
        #expect(receivedError == true)

        cancellable.cancel()
    }

    @Test
    func anyPublisherErasure() throws {
        let subject = PassthroughSubject<Int, Never>()

        let publisher: AnyPublisher<Int, Never> = subject.eraseToAnyPublisher()

        var received: [Int] = []

        let cancellable = publisher.sink(
            receiveValue: { received.append($0) }
        )

        subject.send(1)
        subject.send(2)
        subject.send(3)

        #expect(received == [1, 2, 3])

        cancellable.cancel()
    }

    @Test
    func anyPublisherErrorErasure() throws {
        let subject = PassthroughSubject<String, Error>()

        let publisher: AnyPublisher<String, Error> = subject.eraseToAnyPublisher()

        var received: [String] = []
        var errorCount = 0

        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                if case .failure = completion {
                    errorCount += 1
                }
            },
            receiveValue: { received.append($0) }
        )

        subject.send("hello")
        subject.send(completion: .failure(URLError(.timedOut)))

        #expect(received == ["hello"])
        #expect(errorCount == 1)

        cancellable.cancel()
    }

    @Test
    func publisherMapTransformation() throws {
        let subject = PassthroughSubject<Int, Never>()

        let publisher = subject
            .map { $0 * 2 }
            .map { String($0) }

        var received: [String] = []

        let cancellable = publisher.sink(
            receiveValue: { received.append($0) }
        )

        subject.send(1)
        subject.send(2)
        subject.send(3)

        #expect(received == ["2", "4", "6"])

        cancellable.cancel()
    }

    @Test
    func publisherFilterTransformation() throws {
        let subject = PassthroughSubject<Int, Never>()

        let publisher = subject
            .filter { $0 % 2 == 0 }

        var received: [Int] = []

        let cancellable = publisher.sink(
            receiveValue: { received.append($0) }
        )

        subject.send(1)
        subject.send(2)
        subject.send(3)
        subject.send(4)

        #expect(received == [2, 4])

        cancellable.cancel()
    }

    @Test
    func publisherMultipleSubscribers() throws {
        let subject = PassthroughSubject<String, Never>()

        var received1: [String] = []
        var received2: [String] = []

        let cancellable1 = subject.sink(
            receiveValue: { received1.append($0) }
        )

        let cancellable2 = subject.sink(
            receiveValue: { received2.append($0) }
        )

        subject.send("hello")
        subject.send("world")

        #expect(received1 == ["hello", "world"])
        #expect(received2 == ["hello", "world"])

        cancellable1.cancel()
        cancellable2.cancel()
    }

    @Test
    func publisherCancelDoesNotSend() throws {
        let subject = PassthroughSubject<String, Never>()

        var received: [String] = []

        let cancellable = subject.sink(
            receiveValue: { received.append($0) }
        )

        cancellable.cancel()
        subject.send("after cancel")

        #expect(received.isEmpty)
    }

    @Test
    func publisherFlatMap() throws {
        let subject = PassthroughSubject<Int, Never>()

        let publisher = subject
            .flatMap { value -> AnyPublisher<String, Never> in
                Just("value_\(value)").eraseToAnyPublisher()
            }

        var received: [String] = []

        let cancellable = publisher.sink(
            receiveValue: { received.append($0) }
        )

        subject.send(1)
        subject.send(2)
        subject.send(3)

        #expect(received == ["value_1", "value_2", "value_3"])

        cancellable.cancel()
    }

    @Test
    func publisherRemoveDuplicates() throws {
        let subject = PassthroughSubject<Int, Never>()

        let publisher = subject
            .removeDuplicates()

        var received: [Int] = []

        let cancellable = publisher.sink(
            receiveValue: { received.append($0) }
        )

        subject.send(1)
        subject.send(1)
        subject.send(2)
        subject.send(2)
        subject.send(1)

        #expect(received == [1, 2, 1])

        cancellable.cancel()
    }
}

// MARK: - Async Stream to Combine Bridge Tests

struct AsyncCombineBridgeTests {
    @Test
    func passthroughSubjectWithDirectSend() throws {
        let subject = PassthroughSubject<Int, Error>()

        var received: [Int] = []
        var completed = false

        let cancellable = subject.sink(
            receiveCompletion: { completion in
                if case .finished = completion {
                    completed = true
                }
            },
            receiveValue: { received.append($0) }
        )

        // Send values directly (synchronously)
        subject.send(1)
        subject.send(2)
        subject.send(3)
        subject.send(completion: .finished)

        #expect(received == [1, 2, 3])
        #expect(completed == true)

        cancellable.cancel()
    }
}
