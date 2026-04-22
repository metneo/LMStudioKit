import Testing
@testable import LMStudioKit
import Foundation

// MARK: - ResponseStats Tests

struct ResponseStatsTests {
    @Test
    func decoding() throws {
        let json = #"{"input_tokens": 100, "total_output_tokens": 50, "reasoning_output_tokens": 10, "tokens_per_second": 25.5}"#.data(using: .utf8)!
        let stats = try JSONDecoder().decode(ResponseStats.self, from: json)
        #expect(stats.inputTokens == 100)
        #expect(stats.totalOutputTokens == 50)
        #expect(stats.tokensPerSecond == 25.5)
    }

    @Test
    func decodingWithMissingFields() throws {
        let json = #"{"input_tokens": 50, "total_output_tokens": 25}"#.data(using: .utf8)!
        let stats = try JSONDecoder().decode(ResponseStats.self, from: json)
        #expect(stats.inputTokens == 50)
        #expect(stats.tokensPerSecond == nil)
    }

    @Test
    func decodingAllOptionalFields() throws {
        let json = #"{"input_tokens": 100, "total_output_tokens": 50, "reasoning_output_tokens": 10, "tokens_per_second": 25.5, "time_to_first_token_seconds": 0.3, "model_load_time_seconds": 1.2}"#.data(using: .utf8)!
        let stats = try JSONDecoder().decode(ResponseStats.self, from: json)
        #expect(stats.timeToFirstTokenSeconds == 0.3)
        #expect(stats.modelLoadTimeSeconds == 1.2)
        #expect(stats.reasoningOutputTokens == 10)
    }
}

// MARK: - ChatResponse Tests

struct ChatResponseTests {
    @Test
    func decoding() throws {
        let json = #"{"model_instance_id": "inst-123", "output": [{"type": "message", "content": "Hello!"}], "response_id": "resp-456"}"#.data(using: .utf8)!
        let response = try JSONDecoder().decode(ChatResponse.self, from: json)
        #expect(response.modelInstanceID == "inst-123")
        #expect(response.output?.count == 1)
        #expect(response.responseID == "resp-456")
    }

    @Test
    func decodingWithMultipleOutputs() throws {
        let json = #"{"output": [{"type": "reasoning", "content": "Thinking..."}, {"type": "message", "content": "Hi!"}]}"#.data(using: .utf8)!
        let response = try JSONDecoder().decode(ChatResponse.self, from: json)
        #expect(response.output?.count == 2)
    }

    @Test
    func decodingWithStats() throws {
        let json = #"{"output": [{"type": "message", "content": "Hi"}], "stats": {"input_tokens": 10, "total_output_tokens": 5, "tokens_per_second": 15.0}}"#.data(using: .utf8)!
        let response = try JSONDecoder().decode(ChatResponse.self, from: json)
        #expect(response.stats?.inputTokens == 10)
        #expect(response.stats?.tokensPerSecond == 15.0)
    }

    @Test
    func decodingWithToolCallOutput() throws {
        let json = #"{"output": [{"type": "tool_call", "tool": "search", "arguments": {"q": "swift"}}]}"#.data(using: .utf8)!
        let response = try JSONDecoder().decode(ChatResponse.self, from: json)
        #expect(response.output?.count == 1)
        if case .toolCall(let tool, _, _, _) = response.output?.first {
            #expect(tool == "search")
        } else {
            Issue.record("Expected tool call output item")
        }
    }

    @Test
    func decodingEmptyOutput() throws {
        let json = #"{"output": []}"#.data(using: .utf8)!
        let response = try JSONDecoder().decode(ChatResponse.self, from: json)
        #expect(response.output?.isEmpty == true)
        #expect(response.stats == nil)
        #expect(response.responseID == nil)
    }
}
