import Foundation

/// Statistics about token usage and generation performance.
///
/// ``ResponseStats`` provides detailed metrics about the chat response,
/// including input/output token counts and generation speed.
///
/// ## See Also
///
/// - <https://lmstudio.ai/docs/developer/rest/chat#stats>
public struct ResponseStats: Codable, @unchecked Sendable {
    /// Number of input tokens.
    public let inputTokens: Int

    /// Total number of output tokens generated.
    public let totalOutputTokens: Int

    /// Tokens used for reasoning (if applicable).
    public let reasoningOutputTokens: Int?

    /// Generation speed in tokens per second.
    public let tokensPerSecond: Double?

    /// Time to first token in seconds.
    public let timeToFirstTokenSeconds: Double?

    /// Time to load the model in seconds (if not pre-loaded).
    public let modelLoadTimeSeconds: Double?

    enum CodingKeys: String, CodingKey {
        case inputTokens = "input_tokens"
        case totalOutputTokens = "total_output_tokens"
        case reasoningOutputTokens = "reasoning_output_tokens"
        case tokensPerSecond = "tokens_per_second"
        case timeToFirstTokenSeconds = "time_to_first_token_seconds"
        case modelLoadTimeSeconds = "model_load_time_seconds"
    }
}
