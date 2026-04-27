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

    // MARK: - Encoding Tests

    @Test
    func encoding() throws {
        let stats = ResponseStats(
            inputTokens: 100,
            totalOutputTokens: 50,
            reasoningOutputTokens: 10,
            tokensPerSecond: 25.5,
            timeToFirstTokenSeconds: 0.5,
            modelLoadTimeSeconds: 2.0
        )
        let encoder = JSONEncoder()
        let data = try encoder.encode(stats)
        let json = String(data: data, encoding: .utf8)!

        #expect(json.contains(#""input_tokens":100"#))
        #expect(json.contains(#""total_output_tokens":50"#))
        #expect(json.contains(#""reasoning_output_tokens":10"#))
        #expect(json.contains(#""tokens_per_second":25.5"#))
        #expect(json.contains(#""time_to_first_token_seconds":0.5"#))
        #expect(json.contains(#""model_load_time_seconds":2"#))
    }

    @Test
    func encodingWithOptionalFields() throws {
        let stats = ResponseStats(
            inputTokens: 100,
            totalOutputTokens: 50,
            reasoningOutputTokens: nil,
            tokensPerSecond: nil,
            timeToFirstTokenSeconds: nil,
            modelLoadTimeSeconds: nil
        )
        let encoder = JSONEncoder()
        let data = try encoder.encode(stats)
        let json = String(data: data, encoding: .utf8)!

        #expect(json.contains(#""input_tokens":100"#))
        #expect(json.contains(#""total_output_tokens":50"#))
        #expect(!json.contains("reasoning_output_tokens"))
        #expect(!json.contains("tokens_per_second"))
    }

    @Test
    func encodingAndDecodingRoundTrip() throws {
        let original = ResponseStats(
            inputTokens: 200,
            totalOutputTokens: 100,
            reasoningOutputTokens: 25,
            tokensPerSecond: 30.0,
            timeToFirstTokenSeconds: 0.3,
            modelLoadTimeSeconds: 1.5
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoded = try JSONDecoder().decode(ResponseStats.self, from: data)

        #expect(decoded.inputTokens == 200)
        #expect(decoded.totalOutputTokens == 100)
        #expect(decoded.reasoningOutputTokens == 25)
        #expect(decoded.tokensPerSecond == 30.0)
        #expect(decoded.timeToFirstTokenSeconds == 0.3)
        #expect(decoded.modelLoadTimeSeconds == 1.5)
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

    // MARK: - Encoding Tests

    @Test
    func encoding() throws {
        let stats = ResponseStats(
            inputTokens: 100,
            totalOutputTokens: 50,
            reasoningOutputTokens: nil,
            tokensPerSecond: 25.0,
            timeToFirstTokenSeconds: nil,
            modelLoadTimeSeconds: nil
        )
        let output = OutputItem.message(content: "Hello, world!")
        let response = ChatResponse(
            modelInstanceID: "inst-123",
            output: [output],
            stats: stats,
            responseID: "resp-456"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(response)
        let json = String(data: data, encoding: .utf8)!

        #expect(json.contains(#""model_instance_id":"inst-123""#))
        #expect(json.contains(#""response_id":"resp-456""#))
        #expect(json.contains(#""type":"message""#))
        #expect(json.contains(#""content":"Hello, world!""#))
    }

    @Test
    func encodingWithMinimalFields() throws {
        let response = ChatResponse(
            modelInstanceID: nil,
            output: nil,
            stats: nil,
            responseID: nil
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(response)
        let json = String(data: data, encoding: .utf8)!

        #expect(json == "{}")
    }

    @Test
    func encodingAndDecodingRoundTrip() throws {
        let stats = ResponseStats(
            inputTokens: 150,
            totalOutputTokens: 75,
            reasoningOutputTokens: 20,
            tokensPerSecond: 30.0,
            timeToFirstTokenSeconds: 0.4,
            modelLoadTimeSeconds: 1.2
        )
        let output = OutputItem.reasoning(content: "Thinking...")
        let original = ChatResponse(
            modelInstanceID: "inst-789",
            output: [output],
            stats: stats,
            responseID: "resp-999"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoded = try JSONDecoder().decode(ChatResponse.self, from: data)

        #expect(decoded.modelInstanceID == "inst-789")
        #expect(decoded.responseID == "resp-999")
        #expect(decoded.output?.count == 1)
        #expect(decoded.stats?.inputTokens == 150)
        #expect(decoded.stats?.totalOutputTokens == 75)
    }
}
