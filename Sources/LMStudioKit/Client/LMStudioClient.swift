import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A thread-safe client for interacting with the LM Studio REST API.
///
/// `LMStudioClient` is an actor-isolated client that provides type-safe access to all
/// LM Studio REST API endpoints. It handles connection management, request encoding,
/// response decoding, and error handling.
///
/// ## Overview
///
/// The client supports:
/// - **Chat completions** via ``chat(request:)`` for single requests or ``chatStream(request:)`` for streaming
/// - **Model management** via ``listModels()``, ``loadModel(request:)``, and ``unloadModel(request:)``
/// - **Model downloads** via ``downloadModel(request:)`` and ``downloadStatus(jobId:)``
///
/// ## Thread Safety
///
/// All methods on `LMStudioClient` are actor-isolated, ensuring thread-safe access from any Swift concurrency context:
/// - No locks or synchronization primitives needed
/// - Safe to use from multiple concurrent tasks
/// - No data races possible
///
/// ## Connection Configuration
///
/// Create a client with default settings (localhost:1234):
///
/// ```swift
/// let client = LMStudioClient()
/// ```
///
/// Or with custom configuration:
///
/// ```swift
/// let config = LMStudioConfig(
///     baseURL: URL(string: "http://192.168.1.100:1234")!,
///     apiToken: "optional-token"
/// )
/// let client = LMStudioClient(config: config)
/// ```
///
/// ## Basic Usage
///
/// ```swift
/// let client = LMStudioClient(config: LMStudioConfig(baseURL: URL(string: "http://localhost:1234")!))
///
/// // List available models
/// let models = try await client.listModels()
/// for model in models.models ?? [] {
///     print(model.key ?? model.displayName ?? "unknown")
/// }
///
/// // Send a chat request
/// let request = ChatRequest(model: "my-model", message: "Hello!")
/// let response = try await client.chat(request: request)
/// if case .message(let content) = response.output?.first {
///     print(content)
/// }
/// ```
///
/// - Note: This client uses LM Studio's native REST API (`/api/v1/*` endpoints).
///   It does not use OpenAI-compatible endpoints.
/// - SeeAlso: <https://lmstudio.ai/docs/developer/rest>
public actor LMStudioClient {
    private let config: LMStudioConfig
    private let session: URLSession

    /// Creates a new LM Studio client.
    ///
    /// - Parameter config: Configuration for the client. Defaults to localhost:1234.
    public init(config: LMStudioConfig = LMStudioConfig()) {
        self.config = config
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 300
        self.session = URLSession(configuration: configuration)
    }

    // MARK: - Chat

    /// Creates a chat completion using the native LM Studio REST API.
    ///
    /// Sends a ``ChatRequest`` to the server and returns a ``ChatResponse`` containing
    /// the model's reply as ``OutputItem`` outputs.
    ///
    /// - Parameter request: The ``ChatRequest`` containing the model identifier, input messages,
    ///   and generation parameters (temperature, max tokens, etc.).
    /// - Returns: A ``ChatResponse`` containing the model's output and ``ResponseStats``.
    /// - Throws: ``LMStudioError/invalidResponse`` if the server returns an invalid response,
    ///   or ``LMStudioError/httpError(_:_:)`` for HTTP error status codes.
    ///
    /// ## See Also
    ///
    /// - <https://lmstudio.ai/docs/developer/rest/chat>
    /// - ``chatStream(request:)`` for streaming responses
    /// - ``SSEEvent`` for all available streaming event types
    ///
    /// ### Example
    ///
    /// ```swift
    /// let request = ChatRequest(
    ///     model: "my-model",
    ///     message: "What is Swift?",
    ///     temperature: 0.7,
    ///     maxOutputTokens: 500
    /// )
    /// let response = try await client.chat(request: request)
    ///
    /// // Extract text from the first output item
    /// if case .message(let content) = response.output?.first {
    ///     print(content)
    /// }
    ///
    /// // Check token usage
    /// if let stats = response.stats {
    ///     print("\(stats.inputTokens) input, \(stats.totalOutputTokens) output tokens")
    ///     print("\(stats.tokensPerSecond ?? 0) tokens/second")
    /// }
    /// ```
    public func chat(request: ChatRequest) async throws -> ChatResponse {
        let encoder = JSONEncoder()
        let body = try encoder.encode(request)        
        let urlRequest = try await makeRequest(path: "api/v1/chat", method: "POST", body: body)
        return try await performRequest(urlRequest)
    }

    /// Creates a streaming chat completion using the native LM Studio REST API.
    ///
    /// Returns an async stream of ``SSEEvent`` values as the model generates output.
    /// Each event represents a stage in the streaming response lifecycle.
    ///
    /// - Parameter request: The ``ChatRequest`` containing model and input details.
    /// - Returns: An ``AsyncThrowingStream`` of ``SSEEvent`` values.
    /// - Throws: ``LMStudioError`` for request or streaming errors.
    ///
    /// ## Streaming Lifecycle
    ///
    /// The stream emits events in this approximate order:
    /// 1. ``SSEEvent/chatStart`` - Chat session initialized
    /// 2. ``SSEEvent/modelLoadStart`` / ``SSEEvent/modelLoadProgress`` / ``SSEEvent/modelLoadEnd`` - Model loading
    /// 3. ``SSEEvent/promptProcessingStart`` / ``SSEEvent/promptProcessingEnd`` - Prompt processing
    /// 4. ``SSEEvent/reasoningStart`` / ``SSEEvent/reasoningDelta`` / ``SSEEvent/reasoningEnd`` - Reasoning (if enabled)
    /// 5. ``SSEEvent/messageDelta`` - Incremental text output
    /// 6. ``SSEEvent/toolCallStart`` / ``SSEEvent/toolCallArguments`` / ``SSEEvent/toolCallSuccess`` - Tool calls (if triggered)
    /// 7. ``SSEEvent/chatEnd`` - Final response with stats
    ///
    /// ## See Also
    ///
    /// - <https://lmstudio.ai/docs/developer/rest/streaming-events>
    /// - ``chat(request:)`` for non-streaming responses
    ///
    /// ### Example
    ///
    /// ```swift
    /// let request = ChatRequest(
    ///     model: "my-model",
    ///     message: "Tell me a story",
    ///     temperature: 0.7
    /// )
    ///
    /// for try await event in client.chatStream(request: request) {
    ///     switch event {
    ///     case .messageDelta(let data):
    ///         print(data.content ?? "", terminator: "")
    ///
    ///     case .reasoningDelta(let data):
    ///         print("[Thinking: \(data.content ?? "")]", terminator: "")
    ///
    ///     case .toolCallStart(let data):
    ///         print("Calling tool: \(data.tool ?? "")")
    ///
    ///     case .toolCallSuccess(let data):
    ///         print("Tool result: \(data.output ?? "")")
    ///
    ///     case .chatEnd(let data):
    ///         print("\nDone!")
    ///         print("\(data.result?.stats?.totalOutputTokens ?? 0) tokens generated")
    ///
    ///     case .error(let error):
    ///         print("Error: \(error.error?.message ?? "unknown")")
    ///
    ///     default:
    ///         break
    ///     }
    /// }
    /// ```
    public func chatStream(request: ChatRequest) -> AsyncThrowingStream<SSEEvent, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let stream = try await performStreamingChat(request: request)
                    for try await event in stream {
                        continuation.yield(event)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    private func performStreamingChat(request: ChatRequest) async throws -> AsyncThrowingStream<SSEEvent, Error> {
        // Create a modified request with streaming enabled
        let streamingRequest = request.withStream(true)

        let encoder = JSONEncoder()
        let body = try encoder.encode(streamingRequest)
        let urlRequest = try await makeRequest(path: "api/v1/chat", method: "POST", body: body)

        #if canImport(Darwin)
        let (bytes, response) = try await session.bytes(for: urlRequest)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LMStudioError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            var data = Data()
            for try await byte in bytes {
                data.append(byte)
            }
            throw LMStudioError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        return AsyncThrowingStream { continuation in
            Task {
                do {
                    var eventType: String?
                    var dataBuffer = Data()

                    for try await byte in bytes {
                        if byte == 10 { // newline
                            let line = String(data: dataBuffer, encoding: .utf8) ?? ""

                            if line.hasPrefix("event: ") {
                                // Extract event type
                                eventType = String(line.dropFirst("event: ".count)).trimmingCharacters(in: .whitespacesAndNewlines)
                            } else if line.hasPrefix("data: ") {
                                // Extract data
                                let jsonString = String(line.dropFirst("data: ".count)).trimmingCharacters(in: .whitespacesAndNewlines)

                                if jsonString == "[DONE]" || (eventType == nil && jsonString.isEmpty) {
                                    // Check if this is just a heartbeat/keep-alive
                                    if eventType != nil {
                                        continuation.finish()
                                        return
                                    }
                                } else if let type = eventType, let jsonData = jsonString.data(using: .utf8) {
                                    let event = try SSEEvent.decode(eventType: type, data: jsonData)
                                    continuation.yield(event)
                                }

                                eventType = nil
                            }

                            dataBuffer = Data()
                        } else {
                            dataBuffer.append(byte)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
        #else
        throw LMStudioError.streamingError("Streaming is not supported on this platform")
        #endif
    }

    // MARK: - Streaming

    /// Starts a streaming chat session.
    ///
    /// - Parameter request: The chat request.
    /// - Returns: An async stream of SSE events.
    internal func startStreamingChat(request: ChatRequest) -> AsyncThrowingStream<SSEEvent, Error> {
        AsyncThrowingStream { continuation in
            Task {
                do {
                    let stream = try await performStreamingChat(request: request)
                    for try await event in stream {
                        continuation.yield(event)
                    }
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }

    // MARK: - Models

    /// Lists all models available on the server.
    ///
    /// Returns a ``ModelListResponse`` containing an array of ``ModelInfo`` objects,
    /// each with details like model key, display name, size, quantization, and
    /// currently loaded instances.
    ///
    /// - Returns: A ``ModelListResponse`` with available models.
    /// - Throws: ``LMStudioError`` for HTTP errors.
    ///
    /// ### Example
    ///
    /// ```swift
    /// let models = try await client.listModels()
    /// for model in models.models ?? [] {
    ///     print("\(model.key ?? model.displayName ?? "unknown")")
    ///     print("  Size: \(model.sizeBytes ?? 0) bytes")
    ///     print("  Format: \(model.format ?? "unknown")")
    ///     if let instances = model.loadedInstances, !instances.isEmpty {
    ///         print("  Loaded: \(instances.count) instance(s)")
    ///     }
    /// }
    /// ```
    public func listModels() async throws -> ModelListResponse {
        let urlRequest = try await makeRequest(path: "api/v1/models")
        return try await performRequest(urlRequest)
    }

    /// Loads a model into memory.
    ///
    /// Loads the specified model onto the GPU/CPU so it can be used for inference.
    /// Returns a ``ModelLoadResponse`` with an instance ID used to identify the loaded model.
    ///
    /// - Parameter request: The ``ModelLoadRequest`` specifying the model identifier and optional load config.
    /// - Returns: A ``ModelLoadResponse`` containing the instance ID and status.
    /// - Throws: ``LMStudioError`` for HTTP errors.
    ///
    /// ### Example
    ///
    /// ```swift
    /// let request = ModelLoadRequest(
    ///     model: "llama-3-8b",
    ///     contextLength: 4096,
    ///     flashAttention: true
    /// )
    /// let response = try await client.loadModel(request: request)
    /// print("Loaded: \(response.instanceId ?? "")")
    /// print("Load time: \(response.loadTimeSeconds ?? 0)s")
    /// ```
    public func loadModel(request: ModelLoadRequest) async throws -> ModelLoadResponse {
        let encoder = JSONEncoder()
        let body = try encoder.encode(request)
        let urlRequest = try await makeRequest(path: "api/v1/models/load", method: "POST", body: body)
        return try await performRequest(urlRequest)
    }

    /// Unloads a model from memory.
    ///
    /// Frees memory by removing the specified model instance from memory.
    /// Use the instance ID returned by ``loadModel(request:)``.
    ///
    /// - Parameter request: The ``ModelUnloadRequest`` with the instance ID to unload.
    /// - Returns: A ``ModelUnloadResponse`` confirming the unloaded instance ID.
    /// - Throws: ``LMStudioError`` for HTTP errors.
    ///
    /// ### Example
    ///
    /// ```swift
    /// let request = ModelUnloadRequest(instanceId: "inst-abc123")
    /// let response = try await client.unloadModel(request: request)
    /// print("Unloaded: \(response.instanceId ?? "")")
    /// ```
    public func unloadModel(request: ModelUnloadRequest) async throws -> ModelUnloadResponse {
        let body = try JSONEncoder().encode(request)
        let urlRequest = try await makeRequest(path: "api/v1/models/unload", method: "POST", body: body)
        return try await performRequest(urlRequest)
    }

    // MARK: - Downloads

    /// Downloads a model from Hugging Face.
    ///
    /// Initiates a model download from the Hugging Face model hub.
    /// Use ``downloadStatus(jobId:)`` to monitor progress.
    ///
    /// - Parameter request: The ``ModelDownloadRequest`` with the model identifier and optional quantization.
    /// - Returns: A ``ModelDownloadResponse`` with the job ID and initial status.
    /// - Throws: ``LMStudioError`` for HTTP errors.
    ///
    /// ### Example
    ///
    /// ```swift
    /// let request = ModelDownloadRequest(
    ///     model: "lmstudio-community/llama-3-8b",
    ///     quantization: "Q4_K_M"
    /// )
    /// let response = try await client.downloadModel(request: request)
    /// print("Job ID: \(response.jobId ?? "")")
    /// print("Status: \(response.status)")
    /// ```
    public func downloadModel(request: ModelDownloadRequest) async throws -> ModelDownloadResponse {
        let encoder = JSONEncoder()
        let body = try encoder.encode(request)
        let urlRequest = try await makeRequest(path: "api/v1/models/download", method: "POST", body: body)
        return try await performRequest(urlRequest)
    }

    /// Gets the status of a model download.
    ///
    /// Returns progress information for a download job, including bytes downloaded,
    /// total size, and speed.
    ///
    /// - Parameter jobId: The job ID returned by ``downloadModel(request:)``.
    /// - Returns: A ``ModelDownloadStatusResponse`` with download progress.
    /// - Throws: ``LMStudioError`` for HTTP errors.
    ///
    /// ### Example
    ///
    /// ```swift
    /// let status = try await client.downloadStatus(jobId: "job-abc123")
    /// print("Status: \(status.status)")
    /// print("Progress: \(status.downloadedBytes ?? 0) / \(status.totalSizeBytes ?? 0) bytes")
    /// print("Speed: \(status.speedBytesPerSecond ?? 0) bytes/s")
    /// ```
    public func downloadStatus(jobId: String) async throws -> ModelDownloadStatusResponse {
        let urlRequest = try await makeRequest(path: "api/v1/models/download/status?job_id=\(jobId.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? jobId)")
        return try await performRequest(urlRequest)
    }

    // MARK: - Private Methods

    private func makeRequest(path: String, method: String = "GET", body: Data? = nil) async throws -> URLRequest {
        let url = config.baseURL.appendingPathComponent(path)
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if let token = config.apiToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body = body {
            request.httpBody = body
        }

        return request
    }

    private func performRequest<T: Decodable>(_ request: URLRequest) async throws -> T {
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LMStudioError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw LMStudioError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
