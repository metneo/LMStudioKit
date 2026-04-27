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

    // MARK: - Encoding Tests for SSEEvent Data Structs

    @Test
    func chatStartDataEncoding() throws {
        let data = ChatStartData(modelInstanceId: "inst-123")
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(data)
        let json = String(data: jsonData, encoding: .utf8)!

        #expect(json.contains(#""model_instance_id":"inst-123""#))
    }

    @Test
    func modelLoadProgressDataEncoding() throws {
        let data = ModelLoadProgressData(modelInstanceId: "inst-456", progress: 0.75)
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(data)
        let json = String(data: jsonData, encoding: .utf8)!

        #expect(json.contains(#""model_instance_id":"inst-456""#))
        #expect(json.contains(#""progress":0.75"#))
    }

    @Test
    func modelLoadEndDataEncoding() throws {
        let data = ModelLoadEndData(modelInstanceId: "inst-789", loadTimeSeconds: 3.5)
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(data)
        let json = String(data: jsonData, encoding: .utf8)!

        #expect(json.contains(#""model_instance_id":"inst-789""#))
        #expect(json.contains(#""load_time_seconds":3.5"#))
    }

    @Test
    func reasoningDeltaDataEncoding() throws {
        let data = ReasoningDeltaData(content: "Thinking out loud")
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(data)
        let json = String(data: jsonData, encoding: .utf8)!

        #expect(json.contains(#""content":"Thinking out loud""#))
    }

    @Test
    func toolCallStartDataEncoding() throws {
        let providerInfo = ToolCallProviderInfo(type: "plugin", pluginId: "my-plugin", serverLabel: nil)
        let data = ToolCallStartData(tool: "get_weather", providerInfo: providerInfo)
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(data)
        let json = String(data: jsonData, encoding: .utf8)!

        #expect(json.contains(#""tool":"get_weather""#))
        #expect(json.contains(#""type":"plugin""#))
        #expect(json.contains(#""plugin_id":"my-plugin""#))
    }

    @Test
    func toolCallArgumentsDataEncoding() throws {
        let argsJson = #"{"location": "NYC", "units": "metric"}"#.data(using: .utf8)!
        let arguments = try JSONDecoder().decode([String: AnyCodable].self, from: argsJson)
        let data = ToolCallArgumentsData(tool: "get_weather", arguments: arguments, providerInfo: nil)
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(data)
        let json = String(data: jsonData, encoding: .utf8)!

        #expect(json.contains(#""tool":"get_weather""#))
        #expect(json.contains(#""location":"NYC""#))
        #expect(json.contains(#""units":"metric""#))
    }

    @Test
    func toolCallSuccessDataEncoding() throws {
        let argsJson = #"{"temp": 72}"#.data(using: .utf8)!
        let arguments = try JSONDecoder().decode([String: AnyCodable].self, from: argsJson)
        let providerInfo = ToolCallProviderInfo(type: "ephemeral_mcp", pluginId: nil, serverLabel: "weather-api")
        let data = ToolCallSuccessData(tool: "get_weather", arguments: arguments, output: "Sunny, 72°F", providerInfo: providerInfo)
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(data)
        let json = String(data: jsonData, encoding: .utf8)!

        #expect(json.contains(#""tool":"get_weather""#))
        #expect(json.contains(#""output":"Sunny, 72°F""#))
        #expect(json.contains(#""type":"ephemeral_mcp""#))
        #expect(json.contains(#""server_label":"weather-api""#))
    }

    @Test
    func toolCallFailureMetadataEncoding() throws {
        let argsJson = #"{"invalid": "args"}"#.data(using: .utf8)!
        let arguments = try JSONDecoder().decode([String: AnyCodable].self, from: argsJson)
        let metadata = ToolCallFailureMetadata(type: "invalid_arguments", toolName: "unknown_tool", arguments: arguments)
        let failureData = ToolCallFailureData(reason: "Invalid arguments provided", metadata: metadata)
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(failureData)
        let json = String(data: jsonData, encoding: .utf8)!

        #expect(json.contains(#""reason":"Invalid arguments provided""#))
        #expect(json.contains(#""type":"invalid_arguments""#))
        #expect(json.contains(#""tool_name":"unknown_tool""#))
    }

    @Test
    func messageDeltaDataEncoding() throws {
        let data = MessageDeltaData(content: "Hello, world!")
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(data)
        let json = String(data: jsonData, encoding: .utf8)!

        #expect(json.contains(#""content":"Hello, world!""#))
    }

    @Test
    func sseErrorEncoding() throws {
        let error = SSEError(type: "rate_limit", message: "Too many requests", code: "429", param: nil)
        let data = SSEErrorData(error: error)
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(data)
        let json = String(data: jsonData, encoding: .utf8)!

        // JSON encoding doesn't guarantee property order, so check each property
        #expect(json.contains(#""type":"rate_limit""#))
        #expect(json.contains(#""message":"Too many requests""#))
        #expect(json.contains(#""code":"429""#))
    }

    @Test
    func chatEndDataEncoding() throws {
        let stats = ResponseStats(
            inputTokens: 100,
            totalOutputTokens: 50,
            reasoningOutputTokens: nil,
            tokensPerSecond: 25.0,
            timeToFirstTokenSeconds: nil,
            modelLoadTimeSeconds: nil
        )
        let output = OutputItem.message(content: "Final response")
        let result = ChatEndResult(
            modelInstanceId: "inst-final",
            output: [output],
            stats: stats,
            responseId: "resp-final"
        )
        let data = ChatEndData(result: result)
        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(data)
        let json = String(data: jsonData, encoding: .utf8)!

        #expect(json.contains(#""model_instance_id":"inst-final""#))
        #expect(json.contains(#""response_id":"resp-final""#))
    }

    // MARK: - Round-trip Tests

    @Test
    func toolCallProviderInfoRoundTrip() throws {
        let original = ToolCallProviderInfo(type: "plugin", pluginId: "test-plugin", serverLabel: nil)
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoded = try JSONDecoder().decode(ToolCallProviderInfo.self, from: data)

        #expect(decoded.type == "plugin")
        #expect(decoded.pluginId == "test-plugin")
        #expect(decoded.serverLabel == nil)
    }

    @Test
    func toolCallFailureMetadataRoundTrip() throws {
        let argsJson = #"{"bad": "args"}"#.data(using: .utf8)!
        let arguments = try JSONDecoder().decode([String: AnyCodable].self, from: argsJson)
        let original = ToolCallFailureMetadata(
            type: "invalid_name",
            toolName: "bad_tool",
            arguments: arguments
        )
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoded = try JSONDecoder().decode(ToolCallFailureMetadata.self, from: data)

        #expect(decoded.type == "invalid_name")
        #expect(decoded.toolName == "bad_tool")
        #expect((decoded.arguments?["bad"]?.value as? String) == "args")
    }

    @Test
    func sseErrorRoundTrip() throws {
        let original = SSEError(type: "server_error", message: "Internal error", code: "500", param: "model")
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoded = try JSONDecoder().decode(SSEError.self, from: data)

        #expect(decoded.type == "server_error")
        #expect(decoded.message == "Internal error")
        #expect(decoded.code == "500")
        #expect(decoded.param == "model")
    }

    @Test
    func chatEndResultRoundTrip() throws {
        let stats = ResponseStats(
            inputTokens: 200,
            totalOutputTokens: 100,
            reasoningOutputTokens: nil,
            tokensPerSecond: 20.0,
            timeToFirstTokenSeconds: nil,
            modelLoadTimeSeconds: nil
        )
        let original = ChatEndResult(
            modelInstanceId: "inst-roundtrip",
            output: [OutputItem.message(content: "Test")],
            stats: stats,
            responseId: "resp-roundtrip"
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        let decoded = try JSONDecoder().decode(ChatEndResult.self, from: data)

        #expect(decoded.modelInstanceId == "inst-roundtrip")
        #expect(decoded.responseId == "resp-roundtrip")
        #expect(decoded.output?.count == 1)
        #expect(decoded.stats?.inputTokens == 200)
    }
}
