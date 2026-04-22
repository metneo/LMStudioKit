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
}
