import Testing
@testable import LMStudioKit
import Foundation

// MARK: - ChatInput Tests

struct ChatInputTests {
    @Test
    func textInputEncoding() throws {
        let input = ChatInput.text(content: "Hello, world!")
        let encoder = JSONEncoder()
        let data = try encoder.encode(input)
        let json = String(data: data, encoding: .utf8)!
        #expect(json.contains("\"type\":\"text\""))
        #expect(json.contains("\"content\":\"Hello, world!\""))
    }

    @Test
    func imageInputEncoding() throws {
        let input = ChatInput.image(dataURL: "data:image/png;base64,abc123")
        let encoder = JSONEncoder()
        let data = try encoder.encode(input)
        let json = String(data: data, encoding: .utf8)!
        #expect(json.contains("\"type\":\"image\""))
        #expect(json.contains("data_url"))
    }

    @Test
    func textInputDecoding() throws {
        let json = #"{"type": "text", "content": "Hello!"}"#.data(using: .utf8)!
        let input = try JSONDecoder().decode(ChatInput.self, from: json)
        if case .text(let content) = input {
            #expect(content == "Hello!")
        } else {
            Issue.record("Expected text input")
        }
    }

    @Test
    func textInputDecodingLegacyMessageType() throws {
        let json = #"{"type": "message", "content": "Hello!"}"#.data(using: .utf8)!
        let input = try JSONDecoder().decode(ChatInput.self, from: json)
        if case .text(let content) = input {
            #expect(content == "Hello!")
        } else {
            Issue.record("Expected text input")
        }
    }

    @Test
    func imageInputDecoding() throws {
        let json = #"{"type": "image", "data_url": "data:image/jpeg;base64,xyz789"}"#.data(using: .utf8)!
        let input = try JSONDecoder().decode(ChatInput.self, from: json)
        if case .image(let dataURL) = input {
            #expect(dataURL == "data:image/jpeg;base64,xyz789")
        } else {
            Issue.record("Expected image input")
        }
    }

    @Test
    func unknownTypeThrows() {
        let json = #"{"type": "video", "content": "..."}"#.data(using: .utf8)!
        #expect(throws: (any Error).self) {
            _ = try JSONDecoder().decode(ChatInput.self, from: json)
        }
    }

    @Test
    func textInputRoundTrip() throws {
        let original = ChatInput.text(content: "Round-trip text")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ChatInput.self, from: data)
        if case .text(let content) = decoded {
            #expect(content == "Round-trip text")
        } else {
            Issue.record("Expected text input after round-trip")
        }
    }

    @Test
    func imageInputRoundTrip() throws {
        let original = ChatInput.image(dataURL: "data:image/png;base64,abc123")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ChatInput.self, from: data)
        if case .image(let dataURL) = decoded {
            #expect(dataURL == "data:image/png;base64,abc123")
        } else {
            Issue.record("Expected image input after round-trip")
        }
    }
}
