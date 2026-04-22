import Foundation

#if canImport(Combine)
import Combine

// MARK: - Chat Stream Publisher

extension LMStudioClient {
    /// Creates a publisher that emits streaming chat events.
    ///
    /// - Parameter request: The chat request.
    /// - Returns: A publisher that emits `SSEEvent` values and completes or fails.
    ///
    /// Example:
    /// ```swift
    /// let request = ChatRequest(model: "my-model", message: "Hello!")
    /// publisher = client.chatStreamPublisher(request: request)
    ///
    /// cancellable = publisher
    ///     .sink(
    ///         receiveCompletion: { completion in
    ///             if case .failure(let error) = completion {
    ///                 print("Error: \(error)")
    ///             }
    ///         },
    ///         receiveValue: { event in
    ///             if case .messageDelta(let data) = event {
    ///                 print(data.content ?? "", terminator: "")
    ///             }
    ///         }
    ///     )
    /// ```
    public func chatStreamPublisher(request: ChatRequest) -> AnyPublisher<SSEEvent, Error> {
        let subject = PassthroughSubject<SSEEvent, Error>()

        Task {
            do {
                let stream = startStreamingChat(request: request)
                for try await event in stream {
                    subject.send(event)
                }
                subject.send(completion: .finished)
            } catch {
                subject.send(completion: .failure(error))
            }
        }

        return subject.eraseToAnyPublisher()
    }
}
#endif