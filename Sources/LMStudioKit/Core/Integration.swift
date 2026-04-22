import Foundation

/// An integration to enable for a chat request.
///
/// ``Integration`` allows use of plugins and MCP servers for extended capabilities
/// like tool calling and external data sources.
///
/// ## See Also
///
/// - <https://lmstudio.ai/docs/developer/rest/chat#integrations>
public enum Integration: Codable, Sendable {
    /// A plugin integration.
    case plugin(id: String, allowedTools: [String]?)

    /// An ephemeral MCP server integration.
    case ephemeralMCP(serverLabel: String, serverURL: String, allowedTools: [String]?)

    enum CodingKeys: String, CodingKey {
        case type, id, allowedTools = "allowed_tools", serverLabel = "server_label", serverURL = "server_url"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "plugin":
            let id = try container.decode(String.self, forKey: .id)
            let allowedTools = try container.decodeIfPresent([String].self, forKey: .allowedTools)
            self = .plugin(id: id, allowedTools: allowedTools)
        case "ephemeral_mcp":
            let serverLabel = try container.decode(String.self, forKey: .serverLabel)
            let serverURL = try container.decode(String.self, forKey: .serverURL)
            let allowedTools = try container.decodeIfPresent([String].self, forKey: .allowedTools)
            self = .ephemeralMCP(serverLabel: serverLabel, serverURL: serverURL, allowedTools: allowedTools)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown integration type")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .plugin(let id, let allowedTools):
            try container.encode("plugin", forKey: .type)
            try container.encode(id, forKey: .id)
            try container.encodeIfPresent(allowedTools, forKey: .allowedTools)
        case .ephemeralMCP(let serverLabel, let serverURL, let allowedTools):
            try container.encode("ephemeral_mcp", forKey: .type)
            try container.encode(serverLabel, forKey: .serverLabel)
            try container.encode(serverURL, forKey: .serverURL)
            try container.encodeIfPresent(allowedTools, forKey: .allowedTools)
        }
    }
}
