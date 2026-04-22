import Testing
@testable import LMStudioKit
import Foundation

// MARK: - SSEEvent Tests

struct SSEEventTests {
    @Test
    func chatStartDecoding() throws {
        let data = #"{"model_instance_id": "inst-123"}"#.data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "chat.start", data: data)
        if case .chatStart(let eventData) = event {
            #expect(eventData.modelInstanceId == "inst-123")
        } else {
            Issue.record("Expected chatStart")
        }
    }

    @Test
    func modelLoadProgressDecoding() throws {
        let data = #"{"model_instance_id": "inst-123", "progress": 0.5}"#.data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "model_load.progress", data: data)
        if case .modelLoadProgress(let progressData) = event {
            #expect(progressData.progress == 0.5)
        } else {
            Issue.record("Expected modelLoadProgress")
        }
    }

    @Test
    func reasoningDeltaDecoding() throws {
        let data = #"{"content": "Thinking..."}"#.data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "reasoning.delta", data: data)
        if case .reasoningDelta(let deltaData) = event {
            #expect(deltaData.content == "Thinking...")
        } else {
            Issue.record("Expected reasoningDelta")
        }
    }

    @Test
    func toolCallStartDecoding() throws {
        let data = #"{"tool": "get_weather", "provider_info": {"type": "plugin", "plugin_id": "mcp/weather"}}"#.data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "tool_call.start", data: data)
        if case .toolCallStart(let startData) = event {
            #expect(startData.tool == "get_weather")
        } else {
            Issue.record("Expected toolCallStart")
        }
    }

    @Test
    func toolCallSuccessDecoding() throws {
        let data = #"{"tool": "get_weather", "output": "sunny"}"#.data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "tool_call.success", data: data)
        if case .toolCallSuccess(let successData) = event {
            #expect(successData.output == "sunny")
        } else {
            Issue.record("Expected toolCallSuccess")
        }
    }

    @Test
    func toolCallFailureDecoding() throws {
        let data = #"{"reason": "Unknown tool", "metadata": {"type": "invalid_name"}}"#.data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "tool_call.failure", data: data)
        if case .toolCallFailure(let failureData) = event {
            #expect(failureData.reason == "Unknown tool")
        } else {
            Issue.record("Expected toolCallFailure")
        }
    }

    @Test
    func messageDeltaDecoding() throws {
        let data = #"{"content": "Hello!"}"#.data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "message.delta", data: data)
        if case .messageDelta(let deltaData) = event {
            #expect(deltaData.content == "Hello!")
        } else {
            Issue.record("Expected messageDelta")
        }
    }

    @Test
    func errorDecoding() throws {
        let data = #"{"error": {"type": "invalid_request", "message": "Bad request"}}"#.data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "error", data: data)
        if case .error(let errorData) = event {
            #expect(errorData.error?.message == "Bad request")
        } else {
            Issue.record("Expected error")
        }
    }

    @Test
    func chatEndDecoding() throws {
        let data = #"{"result": {"model_instance_id": "inst-123", "stats": {"input_tokens": 10, "total_output_tokens": 5}}}"#.data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "chat.end", data: data)
        if case .chatEnd(let endData) = event {
            #expect(endData.result?.stats?.inputTokens == 10)
        } else {
            Issue.record("Expected chatEnd")
        }
    }

    @Test
    func unknownEventTypeThrows() throws {
        let data = "{}".data(using: .utf8)!
        do {
            _ = try SSEEvent.decode(eventType: "unknown.event", data: data)
            Issue.record("Should have thrown")
        } catch {
            // expected
        }
    }
}
