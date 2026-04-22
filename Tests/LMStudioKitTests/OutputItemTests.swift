import Testing
@testable import LMStudioKit
import Foundation

// MARK: - OutputItem Tests

struct OutputItemTests {
    @Test
    func messageDecoding() throws {
        let json = #"{"type": "message", "content": "Hello!"}"#.data(using: .utf8)!
        let output = try JSONDecoder().decode(OutputItem.self, from: json)
        if case .message(let content) = output {
            #expect(content == "Hello!")
        } else {
            Issue.record("Expected message output")
        }
    }

    @Test
    func reasoningDecoding() throws {
        let json = #"{"type": "reasoning", "content": "Thinking..."}"#.data(using: .utf8)!
        let output = try JSONDecoder().decode(OutputItem.self, from: json)
        if case .reasoning(let content) = output {
            #expect(content == "Thinking...")
        } else {
            Issue.record("Expected reasoning output")
        }
    }

    @Test
    func toolCallDecoding() throws {
        let json = #"{"type": "tool_call", "tool": "get_weather", "arguments": {"location": "NYC"}}"#.data(using: .utf8)!
        let output = try JSONDecoder().decode(OutputItem.self, from: json)
        if case .toolCall(let tool, let arguments, _, _) = output {
            #expect(tool == "get_weather")
            #expect((arguments["location"]?.value as? String) == "NYC")
        } else {
            Issue.record("Expected tool call output")
        }
    }

    @Test
    func invalidToolCallDecoding() throws {
        let json = #"{"type": "invalid_tool_call", "reason": "Unknown tool"}"#.data(using: .utf8)!
        let output = try JSONDecoder().decode(OutputItem.self, from: json)
        if case .invalidToolCall(let reason, _) = output {
            #expect(reason == "Unknown tool")
        } else {
            Issue.record("Expected invalid tool call")
        }
    }

    @Test
    func unknownTypeThrows() {
        let json = #"{"type": "unknown_type", "content": "..."}"#.data(using: .utf8)!
        #expect(throws: (any Error).self) {
            _ = try JSONDecoder().decode(OutputItem.self, from: json)
        }
    }

    @Test
    func messageRoundTrip() throws {
        let original = OutputItem.message(content: "Hello!")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(OutputItem.self, from: data)
        if case .message(let content) = decoded {
            #expect(content == "Hello!")
        } else {
            Issue.record("Expected message after round-trip")
        }
    }

    @Test
    func reasoningRoundTrip() throws {
        let original = OutputItem.reasoning(content: "Step by step...")
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(OutputItem.self, from: data)
        if case .reasoning(let content) = decoded {
            #expect(content == "Step by step...")
        } else {
            Issue.record("Expected reasoning after round-trip")
        }
    }

    @Test
    func invalidToolCallWithMetadata() throws {
        let json = #"{"type": "invalid_tool_call", "reason": "Bad args", "metadata": {"type": "invalid_arguments"}}"#.data(using: .utf8)!
        let output = try JSONDecoder().decode(OutputItem.self, from: json)
        if case .invalidToolCall(let reason, let metadata) = output {
            #expect(reason == "Bad args")
            #expect(metadata != nil)
        } else {
            Issue.record("Expected invalid tool call with metadata")
        }
    }

    @Test
    func toolCallWithOutputAndProviderInfo() throws {
        let json = #"{"type": "tool_call", "tool": "weather", "arguments": {"city": "Paris"}, "output": "Sunny", "provider_info": {"type": "plugin", "plugin_id": "weather-plugin"}}"#.data(using: .utf8)!
        let output = try JSONDecoder().decode(OutputItem.self, from: json)
        if case .toolCall(let tool, let arguments, let toolOutput, let providerInfo) = output {
            #expect(tool == "weather")
            #expect((arguments["city"]?.value as? String) == "Paris")
            #expect(toolOutput == "Sunny")
            #expect(providerInfo != nil)
        } else {
            Issue.record("Expected tool call with output and providerInfo")
        }
    }

    @Test
    func toolCallRoundTrip() throws {
        let json = #"{"type": "tool_call", "tool": "search", "arguments": {"q": "swift"}}"#.data(using: .utf8)!
        let original = try JSONDecoder().decode(OutputItem.self, from: json)
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(OutputItem.self, from: data)
        if case .toolCall(let tool, _, _, _) = decoded {
            #expect(tool == "search")
        } else {
            Issue.record("Expected tool call after round-trip")
        }
    }
}
