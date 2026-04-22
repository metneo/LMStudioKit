import Foundation

/// A request for chat completions using the native LM Studio REST API.
///
/// Use this to send messages to a loaded model and receive responses.
/// ``ChatRequest`` supports text-only messages, multi-modal inputs (text + images),
/// system prompts, sampling parameters, and integrations.
///
/// ## See Also
///
/// - <https://lmstudio.ai/docs/developer/rest/chat>
public struct ChatRequest: Codable, Sendable {
    /// The model identifier to use for completion. Required.
    public let model: String

    /// The input message(s) to send to the model.
    ///
    /// Can be a single text message or an array of mixed content (text, images).
    public let input: [ChatInput]

    /// Optional system prompt to set model behavior.
    public let systemPrompt: String?

    /// Integrations to enable (plugins, MCP servers).
    public let integrations: [Integration]?

    /// Custom HTTP headers to include.
    public let headers: [String: String]?

    /// Whether to stream the response incrementally via SSE.
    ///
    /// Defaults to false.
    public let stream: Bool?

    /// The sampling temperature for generation.
    ///
    /// Range: 0.0 to 1.0.
    public let temperature: Double?

    /// Cumulative probability threshold for nucleus sampling.
    ///
    /// Range: 0.0 to 1.0.
    public let topP: Double?

    /// Limit to top-k most probable tokens.
    public let topK: Int?

    /// Minimum base probability threshold.
    ///
    /// Range: 0.0 to 1.0.
    public let minP: Double?

    /// Repetition penalty applied to tokens.
    ///
    /// A value of 1.0 means no penalty.
    public let repeatPenalty: Double?

    /// Maximum number of tokens to generate in the response.
    public let maxOutputTokens: Int?

    /// Reasoning effort level.
    ///
    /// Supported values: "off", "low", "medium", "high", "on"
    public let reasoning: String?

    /// Number of tokens to include as context.
    public let contextLength: Int?

    /// Whether to store the chat for future reference.
    ///
    /// Defaults to true.
    public let store: Bool?

    /// A previous response ID to append to for continuing conversations.
    public let previousResponseID: String?

    enum CodingKeys: String, CodingKey {
        case model, input, stream, temperature, integrations, headers, reasoning
        case systemPrompt = "system_prompt"
        case topP = "top_p"
        case topK = "top_k"
        case minP = "min_p"
        case repeatPenalty = "repeat_penalty"
        case maxOutputTokens = "max_output_tokens"
        case contextLength = "context_length"
        case store
        case previousResponseID = "previous_response_id"
    }

    /// Creates a new chat request with a text message.
    ///
    /// - Parameters:
    ///   - model: The model identifier to use. Required.
    ///   - message: The text message to send.
    ///   - systemPrompt: Optional system prompt to set model behavior.
    ///   - temperature: Sampling temperature (0.0-1.0).
    ///   - maxOutputTokens: Maximum tokens to generate.
    ///   - stream: Whether to stream the response.
    public init(
        model: String,
        message: String,
        systemPrompt: String? = nil,
        temperature: Double? = nil,
        maxOutputTokens: Int? = nil,
        stream: Bool? = nil
    ) {
        self.model = model
        self.input = [.text(content: message)]
        self.systemPrompt = systemPrompt
        self.temperature = temperature
        self.maxOutputTokens = maxOutputTokens
        self.stream = stream
        self.integrations = nil
        self.headers = nil
        self.topP = nil
        self.topK = nil
        self.minP = nil
        self.repeatPenalty = nil
        self.reasoning = nil
        self.contextLength = nil
        self.store = nil
        self.previousResponseID = nil
    }

    /// Creates a new chat request with an array of chat inputs.
    ///
    /// - Parameters:
    ///   - model: The model identifier to use. Required.
    ///   - input: The array of chat inputs (messages, images).
    ///   - systemPrompt: Optional system prompt to set model behavior.
    ///   - temperature: Sampling temperature (0.0-1.0).
    ///   - maxOutputTokens: Maximum tokens to generate.
    ///   - stream: Whether to stream the response.
    public init(
        model: String,
        input: [ChatInput],
        systemPrompt: String? = nil,
        temperature: Double? = nil,
        maxOutputTokens: Int? = nil,
        stream: Bool? = nil
    ) {
        self.model = model
        self.input = input
        self.systemPrompt = systemPrompt
        self.temperature = temperature
        self.maxOutputTokens = maxOutputTokens
        self.stream = stream
        self.integrations = nil
        self.headers = nil
        self.topP = nil
        self.topK = nil
        self.minP = nil
        self.repeatPenalty = nil
        self.reasoning = nil
        self.contextLength = nil
        self.store = nil
        self.previousResponseID = nil
    }

    /// Creates a new chat request with all parameters specified.
    ///
    /// - Parameters:
    ///   - model: The model identifier to use. Required.
    ///   - input: The input message(s) to send.
    ///   - systemPrompt: Optional system prompt to set model behavior.
    ///   - temperature: Sampling temperature (0.0-1.0).
    ///   - maxOutputTokens: Maximum tokens to generate.
    ///   - stream: Whether to stream the response.
    ///   - topP: Cumulative probability threshold for nucleus sampling.
    ///   - topK: Limit to top-k most probable tokens.
    ///   - minP: Minimum base probability threshold.
    ///   - repeatPenalty: Repetition penalty applied to tokens.
    ///   - reasoning: Reasoning effort level.
    ///   - contextLength: Number of tokens to include as context.
    ///   - store: Whether to store the chat.
    ///   - previousResponseID: Previous response ID to append to.
    ///   - integrations: Integrations to enable.
    ///   - headers: Custom HTTP headers.
    public init(
        model: String,
        input: [ChatInput],
        systemPrompt: String? = nil,
        temperature: Double? = nil,
        maxOutputTokens: Int? = nil,
        stream: Bool? = nil,
        topP: Double? = nil,
        topK: Int? = nil,
        minP: Double? = nil,
        repeatPenalty: Double? = nil,
        reasoning: String? = nil,
        contextLength: Int? = nil,
        store: Bool? = nil,
        previousResponseID: String? = nil,
        integrations: [Integration]? = nil,
        headers: [String: String]? = nil
    ) {
        self.model = model
        self.input = input
        self.systemPrompt = systemPrompt
        self.temperature = temperature
        self.maxOutputTokens = maxOutputTokens
        self.stream = stream
        self.topP = topP
        self.topK = topK
        self.minP = minP
        self.repeatPenalty = repeatPenalty
        self.reasoning = reasoning
        self.contextLength = contextLength
        self.store = store
        self.previousResponseID = previousResponseID
        self.integrations = integrations
        self.headers = headers
    }

    /// Returns a copy of this request with streaming enabled.
    func withStream(_ enabled: Bool) -> ChatRequest {
        ChatRequest(
            model: model,
            input: input,
            systemPrompt: systemPrompt,
            temperature: temperature,
            maxOutputTokens: maxOutputTokens,
            stream: enabled,
            topP: topP,
            topK: topK,
            minP: minP,
            repeatPenalty: repeatPenalty,
            reasoning: reasoning,
            contextLength: contextLength,
            store: store,
            previousResponseID: previousResponseID,
            integrations: integrations,
            headers: headers
        )
    }
}
