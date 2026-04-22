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

    @Test
    func modelLoadStartDecoding() throws {
        let data = #"{"model_instance_id": "inst-abc"}"#.data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "model_load.start", data: data)
        if case .modelLoadStart(let startData) = event {
            #expect(startData.modelInstanceId == "inst-abc")
        } else {
            Issue.record("Expected modelLoadStart")
        }
    }

    @Test
    func modelLoadEndDecoding() throws {
        let data = #"{"model_instance_id": "inst-abc", "load_time_seconds": 3.2}"#.data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "model_load.end", data: data)
        if case .modelLoadEnd(let endData) = event {
            #expect(endData.modelInstanceId == "inst-abc")
            #expect(endData.loadTimeSeconds == 3.2)
        } else {
            Issue.record("Expected modelLoadEnd")
        }
    }

    @Test
    func promptProcessingStartDecoding() throws {
        let data = "{}".data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "prompt_processing.start", data: data)
        if case .promptProcessingStart = event {
            // expected
        } else {
            Issue.record("Expected promptProcessingStart")
        }
    }

    @Test
    func promptProcessingProgressDecoding() throws {
        let data = #"{"progress": 0.75}"#.data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "prompt_processing.progress", data: data)
        if case .promptProcessingProgress(let progressData) = event {
            #expect(progressData.progress == 0.75)
        } else {
            Issue.record("Expected promptProcessingProgress")
        }
    }

    @Test
    func promptProcessingEndDecoding() throws {
        let data = "{}".data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "prompt_processing.end", data: data)
        if case .promptProcessingEnd = event {
            // expected
        } else {
            Issue.record("Expected promptProcessingEnd")
        }
    }

    @Test
    func reasoningStartDecoding() throws {
        let data = "{}".data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "reasoning.start", data: data)
        if case .reasoningStart = event {
            // expected
        } else {
            Issue.record("Expected reasoningStart")
        }
    }

    @Test
    func reasoningEndDecoding() throws {
        let data = "{}".data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "reasoning.end", data: data)
        if case .reasoningEnd = event {
            // expected
        } else {
            Issue.record("Expected reasoningEnd")
        }
    }

    @Test
    func toolCallArgumentsDecoding() throws {
        let data = #"{"tool": "get_weather", "arguments": {"city": "London"}}"#.data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "tool_call.arguments", data: data)
        if case .toolCallArguments(let argsData) = event {
            #expect(argsData.tool == "get_weather")
            #expect((argsData.arguments?["city"]?.value as? String) == "London")
        } else {
            Issue.record("Expected toolCallArguments")
        }
    }

    @Test
    func messageStartDecoding() throws {
        let data = "{}".data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "message.start", data: data)
        if case .messageStart = event {
            // expected
        } else {
            Issue.record("Expected messageStart")
        }
    }

    @Test
    func messageEndDecoding() throws {
        let data = "{}".data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "message.end", data: data)
        if case .messageEnd = event {
            // expected
        } else {
            Issue.record("Expected messageEnd")
        }
    }

    @Test
    func toolCallProviderInfoPluginType() throws {
        let data = #"{"tool": "my_tool", "provider_info": {"type": "plugin", "plugin_id": "my-plugin"}}"#.data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "tool_call.start", data: data)
        if case .toolCallStart(let startData) = event {
            #expect(startData.providerInfo?.type == "plugin")
            #expect(startData.providerInfo?.pluginId == "my-plugin")
        } else {
            Issue.record("Expected toolCallStart")
        }
    }

    @Test
    func toolCallProviderInfoEphemeralMCPType() throws {
        let data = #"{"tool": "weather_tool", "provider_info": {"type": "ephemeral_mcp", "server_label": "weather-server"}}"#.data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "tool_call.start", data: data)
        if case .toolCallStart(let startData) = event {
            #expect(startData.providerInfo?.type == "ephemeral_mcp")
            #expect(startData.providerInfo?.serverLabel == "weather-server")
        } else {
            Issue.record("Expected toolCallStart with ephemeral_mcp")
        }
    }

    @Test
    func chatEndDecodingWithOutput() throws {
        let data = #"{"result": {"model_instance_id": "inst-123", "output": [{"type": "message", "content": "Done!"}], "stats": {"input_tokens": 20, "total_output_tokens": 10}, "response_id": "resp-abc"}}"#.data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "chat.end", data: data)
        if case .chatEnd(let endData) = event {
            #expect(endData.result?.output?.count == 1)
            #expect(endData.result?.responseId == "resp-abc")
        } else {
            Issue.record("Expected chatEnd")
        }
    }

    @Test
    func toolCallSuccessWithArguments() throws {
        let data = #"{"tool": "search", "arguments": {"query": "swift"}, "output": "results here"}"#.data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "tool_call.success", data: data)
        if case .toolCallSuccess(let successData) = event {
            #expect(successData.tool == "search")
            #expect((successData.arguments?["query"]?.value as? String) == "swift")
            #expect(successData.output == "results here")
        } else {
            Issue.record("Expected toolCallSuccess")
        }
    }

    @Test
    func toolCallFailureWithMetadata() throws {
        let data = #"{"reason": "Tool not found", "metadata": {"type": "invalid_name", "tool_name": "bad_tool"}}"#.data(using: .utf8)!
        let event = try SSEEvent.decode(eventType: "tool_call.failure", data: data)
        if case .toolCallFailure(let failureData) = event {
            #expect(failureData.reason == "Tool not found")
            #expect(failureData.metadata?.type == "invalid_name")
            #expect(failureData.metadata?.toolName == "bad_tool")
        } else {
            Issue.record("Expected toolCallFailure")
        }
    }
}
