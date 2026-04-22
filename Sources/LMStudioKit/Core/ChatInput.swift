import Foundation

/// The input content for a chat request.
///
/// Use this to construct the input when sending chat requests.
/// ``ChatInput`` supports both text messages and base64-encoded images.
///
/// ## See Also
///
/// - <https://lmstudio.ai/docs/developer/rest/chat#input>
public enum ChatInput: Codable, Sendable {
    /// A text message input.
    case text(content: String)

    /// An image input with base64-encoded data.
    case image(dataURL: String)

    enum CodingKeys: String, CodingKey {
        case type, content, dataURL = "data_url"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)

        switch type {
        case "text", "message":
            let content = try container.decode(String.self, forKey: .content)
            self = .text(content: content)
        case "image":
            let dataURL = try container.decode(String.self, forKey: .dataURL)
            self = .image(dataURL: dataURL)
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown input type")
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let content):
            try container.encode("text", forKey: .type)
            try container.encode(content, forKey: .content)
        case .image(let dataURL):
            try container.encode("image", forKey: .type)
            try container.encode(dataURL, forKey: .dataURL)
        }
    }
}
