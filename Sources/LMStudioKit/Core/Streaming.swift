import Foundation

// MARK: - Streaming Events

/// Events emitted during streaming chat responses via SSE.
///
/// Each event corresponds to a stage in the streaming response lifecycle,
/// from model loading through to chat completion.
///
/// ## See Also
///
/// - <https://lmstudio.ai/docs/developer/rest/streaming-events>
public enum SSEEvent: Sendable {
    /// Chat session has started.
    case chatStart(ChatStartData)

    /// Model loading has started.
    case modelLoadStart(ModelLoadStartData)

    /// Model loading progress update.
    case modelLoadProgress(ModelLoadProgressData)

    /// Model loading completed.
    case modelLoadEnd(ModelLoadEndData)

    /// Prompt processing has started.
    case promptProcessingStart

    /// Prompt processing progress update.
    case promptProcessingProgress(PromptProcessingProgressData)

    /// Prompt processing completed.
    case promptProcessingEnd

    /// Reasoning phase has started.
    case reasoningStart

    /// Reasoning content delta.
    case reasoningDelta(ReasoningDeltaData)

    /// Reasoning phase completed.
    case reasoningEnd

    /// Tool call has started.
    case toolCallStart(ToolCallStartData)

    /// Tool call arguments delta.
    case toolCallArguments(ToolCallArgumentsData)

    /// Tool call succeeded.
    case toolCallSuccess(ToolCallSuccessData)

    /// Tool call failed.
    case toolCallFailure(ToolCallFailureData)

    /// Message output has started.
    case messageStart

    /// Message content delta.
    case messageDelta(MessageDeltaData)

    /// Message output completed.
    case messageEnd

    /// An error occurred during streaming.
    case error(SSEErrorData)

    /// Chat session has ended with final result.
    case chatEnd(ChatEndData)
}

// MARK: - Chat Start

/// Data for chat.start event.
public struct ChatStartData: Codable, Sendable {
    /// The model instance identifier.
    public let modelInstanceId: String?

    enum CodingKeys: String, CodingKey {
        case modelInstanceId = "model_instance_id"
    }
}

// MARK: - Model Load Events

/// Data for model_load.start event.
public struct ModelLoadStartData: Codable, Sendable {
    /// The model instance identifier.
    public let modelInstanceId: String?

    enum CodingKeys: String, CodingKey {
        case modelInstanceId = "model_instance_id"
    }
}

/// Data for model_load.progress event.
public struct ModelLoadProgressData: Codable, Sendable {
    /// The model instance identifier.
    public let modelInstanceId: String?

    /// Loading progress from 0 to 1.
    public let progress: Double?

    enum CodingKeys: String, CodingKey {
        case modelInstanceId = "model_instance_id"
        case progress
    }
}

/// Data for model_load.end event.
public struct ModelLoadEndData: Codable, Sendable {
    /// The model instance identifier.
    public let modelInstanceId: String?

    /// Time taken to load the model in seconds.
    public let loadTimeSeconds: Double?

    enum CodingKeys: String, CodingKey {
        case modelInstanceId = "model_instance_id"
        case loadTimeSeconds = "load_time_seconds"
    }
}

// MARK: - Prompt Processing Events

/// Data for prompt_processing.progress event.
public struct PromptProcessingProgressData: Codable, Sendable {
    /// Processing progress from 0 to 1.
    public let progress: Double?

    enum CodingKeys: String, CodingKey {
        case progress
    }
}

// MARK: - Reasoning Events

/// Data for reasoning.delta event.
public struct ReasoningDeltaData: Codable, Sendable {
    /// The incremental reasoning content.
    public let content: String?

    enum CodingKeys: String, CodingKey {
        case content
    }
}

// MARK: - Tool Call Events

/// Provider information for tool calls.
public struct ToolCallProviderInfo: Codable, Sendable {
    /// The provider type ("plugin" or "ephemeral_mcp").
    public let type: String?

    /// Plugin identifier (for plugin type).
    public let pluginId: String?

    /// Server label (for ephemeral_mcp type).
    public let serverLabel: String?

    enum CodingKeys: String, CodingKey {
        case type
        case pluginId = "plugin_id"
        case serverLabel = "server_label"
    }
}

/// Data for tool_call.start event.
public struct ToolCallStartData: Codable, Sendable {
    /// The tool name being called.
    public let tool: String?

    /// Provider information.
    public let providerInfo: ToolCallProviderInfo?

    enum CodingKeys: String, CodingKey {
        case tool
        case providerInfo = "provider_info"
    }
}

/// Data for tool_call.arguments event.
public struct ToolCallArgumentsData: Codable, Sendable {
    /// The tool name.
    public let tool: String?

    /// The tool arguments.
    public let arguments: [String: AnyCodable]?

    /// Provider information.
    public let providerInfo: ToolCallProviderInfo?

    enum CodingKeys: String, CodingKey {
        case tool
        case arguments
        case providerInfo = "provider_info"
    }
}

/// Data for tool_call.success event.
public struct ToolCallSuccessData: Codable, Sendable {
    /// The tool name.
    public let tool: String?

    /// The tool arguments.
    public let arguments: [String: AnyCodable]?

    /// The tool output result.
    public let output: String?

    /// Provider information.
    public let providerInfo: ToolCallProviderInfo?

    enum CodingKeys: String, CodingKey {
        case tool
        case arguments
        case output
        case providerInfo = "provider_info"
    }
}

/// Metadata for tool call failures.
public struct ToolCallFailureMetadata: Codable, Sendable {
    /// Error type.
    public let type: String?

    /// The tool name that was invalid.
    public let toolName: String?

    /// Invalid arguments if applicable.
    public let arguments: [String: AnyCodable]?

    enum CodingKeys: String, CodingKey {
        case type
        case toolName = "tool_name"
        case arguments
    }
}

/// Data for tool_call.failure event.
public struct ToolCallFailureData: Codable, Sendable {
    /// Failure reason message.
    public let reason: String?

    /// Error metadata.
    public let metadata: ToolCallFailureMetadata?

    enum CodingKeys: String, CodingKey {
        case reason
        case metadata
    }
}

// MARK: - Message Events

/// Data for message.delta event.
public struct MessageDeltaData: Codable, Sendable {
    /// The incremental message content.
    public let content: String?

    enum CodingKeys: String, CodingKey {
        case content
    }
}

// MARK: - Error Event

/// Error details for error events.
public struct SSEError: Codable, Sendable {
    /// Error type.
    public let type: String?

    /// Error message.
    public let message: String?

    /// Error code if available.
    public let code: String?

    /// Parameter that caused the error.
    public let param: String?

    enum CodingKeys: String, CodingKey {
        case type, message, code, param
    }
}

/// Data for error events.
public struct SSEErrorData: Codable, Sendable {
    /// Error details.
    public let error: SSEError?

    enum CodingKeys: String, CodingKey {
        case error
    }
}

// MARK: - Chat End

/// Result data for chat.end event containing final aggregated response.
public struct ChatEndResult: Codable, Sendable {
    /// The model instance identifier.
    public let modelInstanceId: String?

    /// Final output items.
    public let output: [OutputItem]?

    /// Response statistics.
    public let stats: ResponseStats?

    /// Response identifier.
    public let responseId: String?

    enum CodingKeys: String, CodingKey {
        case modelInstanceId = "model_instance_id"
        case output, stats
        case responseId = "response_id"
    }
}

/// Data for chat.end event.
public struct ChatEndData: Codable, Sendable {
    /// The final result with output and stats.
    public let result: ChatEndResult?

    enum CodingKeys: String, CodingKey {
        case result
    }
}

// MARK: - SSEEvent Decoding

extension SSEEvent {
    /// Creates an SSEEvent from an SSE event type string and JSON data.
    ///
    /// - Parameters:
    ///   - eventType: The SSE event type (e.g., "message.delta", "chat.start")
    ///   - data: The JSON data for the event
    /// - Returns: The parsed SSEEvent
    internal static func decode(eventType: String, data: Data) throws -> SSEEvent {
        let decoder = JSONDecoder()

        switch eventType {
        case "chat.start":
            return .chatStart(try decoder.decode(ChatStartData.self, from: data))

        case "model_load.start":
            return .modelLoadStart(try decoder.decode(ModelLoadStartData.self, from: data))

        case "model_load.progress":
            return .modelLoadProgress(try decoder.decode(ModelLoadProgressData.self, from: data))

        case "model_load.end":
            return .modelLoadEnd(try decoder.decode(ModelLoadEndData.self, from: data))

        case "prompt_processing.start":
            return .promptProcessingStart

        case "prompt_processing.progress":
            return .promptProcessingProgress(try decoder.decode(PromptProcessingProgressData.self, from: data))

        case "prompt_processing.end":
            return .promptProcessingEnd

        case "reasoning.start":
            return .reasoningStart

        case "reasoning.delta":
            return .reasoningDelta(try decoder.decode(ReasoningDeltaData.self, from: data))

        case "reasoning.end":
            return .reasoningEnd

        case "tool_call.start":
            return .toolCallStart(try decoder.decode(ToolCallStartData.self, from: data))

        case "tool_call.arguments":
            return .toolCallArguments(try decoder.decode(ToolCallArgumentsData.self, from: data))

        case "tool_call.success":
            return .toolCallSuccess(try decoder.decode(ToolCallSuccessData.self, from: data))

        case "tool_call.failure":
            return .toolCallFailure(try decoder.decode(ToolCallFailureData.self, from: data))

        case "message.start":
            return .messageStart

        case "message.delta":
            return .messageDelta(try decoder.decode(MessageDeltaData.self, from: data))

        case "message.end":
            return .messageEnd

        case "error":
            return .error(try decoder.decode(SSEErrorData.self, from: data))

        case "chat.end":
            return .chatEnd(try decoder.decode(ChatEndData.self, from: data))

        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: [],
                    debugDescription: "Unknown SSE event type: \(eventType)"
                )
            )
        }
    }
}