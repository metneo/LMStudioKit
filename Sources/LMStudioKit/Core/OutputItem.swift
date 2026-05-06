import Foundation

/// A single output item from a chat response.
///
/// ``OutputItem`` represents one chunk of the model's output, which can be:
/// - ``message(content:)`` - A text message
/// - ``toolCall(tool:arguments:output:providerInfo:)`` - A tool/function call request
/// - ``reasoning(content:)`` - Intermediate reasoning (if reasoning is enabled)
/// - ``invalidToolCall(reason:metadata:)`` - A tool call that failed validation
///
/// ## See Also
///
/// - <https://lmstudio.ai/docs/developer/rest/chat#output>
public enum OutputItem: Codable, Sendable {
    /// A text message output.
    case message(content: String)

    /// A tool call request.
    case toolCall(tool: String, arguments: [String: AnyCodable], output: String?, providerInfo: [String: AnyCodable]?)

    /// A reasoning output.
    case reasoning(content: String)

    /// An invalid tool call with error information.
    case invalidToolCall(reason: String, metadata: [String: AnyCodable]?)

    enum CodingKeys: String, CodingKey {
        case type, content, tool, arguments, output, providerInfo = "provider_info", reason, metadata
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "message":
            let content = try container.decode(String.self, forKey: .content)
            self = .message(content: content)
        case "tool_call":
            let tool = try container.decode(String.self, forKey: .tool)
            let arguments = try container.decode([String: AnyCodable].self, forKey: .arguments)
            let output = try container.decodeIfPresent(String.self, forKey: .output)
            let providerInfo = try container.decodeIfPresent([String: AnyCodable].self, forKey: .providerInfo)
            self = .toolCall(tool: tool, arguments: arguments, output: output, providerInfo: providerInfo)
        case "reasoning":
            let content = try container.decode(String.self, forKey: .content)
            self = .reasoning(content: content)
        case "invalid_tool_call":
            let reason = try container.decode(String.self, forKey: .reason)
            let metadata = try container.decodeIfPresent([String: AnyCodable].self, forKey: .metadata)
            self = .invalidToolCall(reason: reason, metadata: metadata)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown output type")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .message(let content):
            try container.encode("message", forKey: .type)
            try container.encode(content, forKey: .content)
        case .toolCall(let tool, let arguments, let output, let providerInfo):
            try container.encode("tool_call", forKey: .type)
            try container.encode(tool, forKey: .tool)
            try container.encode(arguments, forKey: .arguments)
            try container.encodeIfPresent(output, forKey: .output)
            try container.encodeIfPresent(providerInfo, forKey: .providerInfo)
        case .reasoning(let content):
            try container.encode("reasoning", forKey: .type)
            try container.encode(content, forKey: .content)
        case .invalidToolCall(let reason, let metadata):
            try container.encode("invalid_tool_call", forKey: .type)
            try container.encode(reason, forKey: .reason)
            try container.encodeIfPresent(metadata, forKey: .metadata)
        }
    }
}
