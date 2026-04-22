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
}
