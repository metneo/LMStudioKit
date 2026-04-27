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

    // MARK: - Encoding Tests

    @Test
    func messageEncoding() throws {
        let output = OutputItem.message(content: "Hello!")
        let encoder = JSONEncoder()
        let data = try encoder.encode(output)
        let json = String(data: data, encoding: .utf8)!

        #expect(json.contains(#""type":"message""#))
        #expect(json.contains(#""content":"Hello!""#))
    }

    @Test
    func reasoningEncoding() throws {
        let output = OutputItem.reasoning(content: "Thinking...")
        let encoder = JSONEncoder()
        let data = try encoder.encode(output)
        let json = String(data: data, encoding: .utf8)!

        #expect(json.contains(#""type":"reasoning""#))
        #expect(json.contains(#""content":"Thinking...""#))
    }

    @Test
    func toolCallEncoding() throws {
        let argumentsJson = #"{"location": "NYC"}"#.data(using: .utf8)!
        let arguments = try JSONDecoder().decode([String: AnyCodable].self, from: argumentsJson)
        let output = OutputItem.toolCall(tool: "get_weather", arguments: arguments, output: nil, providerInfo: nil)
        let encoder = JSONEncoder()
        let data = try encoder.encode(output)
        let json = String(data: data, encoding: .utf8)!

        #expect(json.contains(#""type":"tool_call""#))
        #expect(json.contains(#""tool":"get_weather""#))
        #expect(json.contains(#""arguments":{"location":"NYC"}"#))
    }

    @Test
    func toolCallEncodingWithOutputAndProviderInfo() throws {
        let argumentsJson = #"{"query": "weather in NYC"}"#.data(using: .utf8)!
        let arguments = try JSONDecoder().decode([String: AnyCodable].self, from: argumentsJson)
        let providerInfoJson = #"{"type": "plugin", "plugin_id": "weather-plugin"}"#.data(using: .utf8)!
        let providerInfo = try JSONDecoder().decode([String: AnyCodable].self, from: providerInfoJson)
        let output = OutputItem.toolCall(tool: "search", arguments: arguments, output: "Sunny, 72°F", providerInfo: providerInfo)
        let encoder = JSONEncoder()
        let data = try encoder.encode(output)
        let json = String(data: data, encoding: .utf8)!

        #expect(json.contains(#""type":"tool_call""#))
        #expect(json.contains(#""tool":"search""#))
        #expect(json.contains(#""output":"Sunny, 72°F""#))
        #expect(json.contains(#""type":"plugin""#))
        #expect(json.contains(#""plugin_id":"weather-plugin""#))
    }

    @Test
    func invalidToolCallEncoding() throws {
        let metadataJson = #"{"error_code": 404}"#.data(using: .utf8)!
        let metadata = try JSONDecoder().decode([String: AnyCodable].self, from: metadataJson)
        let output = OutputItem.invalidToolCall(reason: "Tool not found", metadata: metadata)
        let encoder = JSONEncoder()
        let data = try encoder.encode(output)
        let json = String(data: data, encoding: .utf8)!

        #expect(json.contains(#""type":"invalid_tool_call""#))
        #expect(json.contains(#""reason":"Tool not found""#))
        #expect(json.contains(#""error_code":404"#))
    }

    @Test
    func encodingAndDecodingRoundTrip() throws {
        let argsJson = #"{"param": 42, "name": "test"}"#.data(using: .utf8)!
        let arguments = try JSONDecoder().decode([String: AnyCodable].self, from: argsJson)
        let providerJson = #"{"type": "mcp"}"#.data(using: .utf8)!
        let providerInfo = try JSONDecoder().decode([String: AnyCodable].self, from: providerJson)

        let original = OutputItem.toolCall(
            tool: "test_tool",
            arguments: arguments,
            output: "success",
            providerInfo: providerInfo
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoded = try JSONDecoder().decode(OutputItem.self, from: data)

        if case .toolCall(let tool, let decodedArgs, let output, let decodedProvider) = decoded {
            #expect(tool == "test_tool")
            #expect((decodedArgs["param"]?.value as? Int) == 42)
            #expect((decodedArgs["name"]?.value as? String) == "test")
            #expect(output == "success")
            #expect((decodedProvider?["type"]?.value as? String) == "mcp")
        } else {
            Issue.record("Expected tool call output after round trip")
        }
    }
}
