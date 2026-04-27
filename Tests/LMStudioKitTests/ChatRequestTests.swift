import Testing
@testable import LMStudioKit
import Foundation

// MARK: - ChatRequest Tests

struct ChatRequestTests {
    @Test
    func basicInitialization() {
        let request = ChatRequest(model: "llama-3", message: "Hello!")
        #expect(request.model == "llama-3")
        #expect(request.input.count == 1)
        #expect(request.systemPrompt == nil)
    }

    @Test
    func fullInitialization() {
        let request = ChatRequest(
            model: "llama-3",
            message: "Hi",
            systemPrompt: "Be helpful.",
            temperature: 0.7,
            maxOutputTokens: 500
        )
        #expect(request.model == "llama-3")
        #expect(request.systemPrompt == "Be helpful.")
        #expect(request.temperature == 0.7)
    }

    @Test
    func withMultipleInputs() {
        let request = ChatRequest(
            model: "llama-3",
            input: [.text(content: "Hello"), .image(dataURL: "data:image/png;base64,abc")]
        )
        #expect(request.input.count == 2)
    }

    @Test
    func withSamplingParameters() {
        let request = ChatRequest(
            model: "llama-3",
            input: [.text(content: "Test")],
            topP: 0.9,
            topK: 40,
            minP: 0.05,
            repeatPenalty: 1.1
        )
        #expect(request.topP == 0.9)
        #expect(request.topK == 40)
    }

    @Test
    func withReasoningAndContext() {
        let request = ChatRequest(
            model: "llama-3",
            input: [.text(content: "Think")],
            reasoning: "high",
            contextLength: 8192
        )
        #expect(request.reasoning == "high")
        #expect(request.contextLength == 8192)
    }

    @Test
    func encodingAndDecoding() throws {
        let request = ChatRequest(
            model: "llama-3",
            message: "Hello",
            temperature: 0.8,
            maxOutputTokens: 100
        )
        let data = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(ChatRequest.self, from: data)
        #expect(decoded.model == "llama-3")
        #expect(decoded.temperature == 0.8)
        #expect(decoded.maxOutputTokens == 100)
    }

    @Test
    func withStream() {
        let request = ChatRequest(model: "llama-3", message: "Hello!")
        let streamingRequest = request.withStream(true)
        #expect(streamingRequest.stream == true)
    }

    // MARK: - Edge Case Tests

    @Test
    func withStreamPreservesOtherFields() {
        let request = ChatRequest(
            model: "llama-3",
            input: [.text(content: "Hello!")],
            systemPrompt: "You are helpful.",
            temperature: 0.7,
            maxOutputTokens: 500,
            topP: 0.9,
            topK: 40,
            minP: 0.05,
            repeatPenalty: 1.1
        )

        let streamingRequest = request.withStream(true)

        #expect(streamingRequest.stream == true)
        #expect(streamingRequest.model == "llama-3")
        #expect(streamingRequest.systemPrompt == "You are helpful.")
        #expect(streamingRequest.temperature == 0.7)
        #expect(streamingRequest.maxOutputTokens == 500)
        #expect(streamingRequest.topP == 0.9)
        #expect(streamingRequest.topK == 40)
    }

    @Test
    func withStreamFalseOverridesTrue() {
        let request = ChatRequest(model: "llama-3", input: [.text(content: "Hello!")], stream: true)
        let nonStreamingRequest = request.withStream(false)
        #expect(nonStreamingRequest.stream == false)
    }

    @Test
    func withStreamOnAlreadyStreamingRequest() {
        let request = ChatRequest(model: "llama-3", input: [.text(content: "Hello!")], stream: true)
        let streamingRequest = request.withStream(true)
        #expect(streamingRequest.stream == true)
    }

    @Test
    func encodingWithAllFields() throws {
        let request = ChatRequest(
            model: "llama-3",
            input: [.text(content: "Test message")],
            systemPrompt: "You are a helpful assistant.",
            temperature: 0.8,
            maxOutputTokens: 200,
            topP: 0.95,
            topK: 50,
            minP: 0.02,
            repeatPenalty: 1.05,
            reasoning: "high",
            contextLength: 4096,
            store: true,
            previousResponseID: "prev-123",
            headers: ["X-Custom": "header"]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = String(data: data, encoding: .utf8)!

        #expect(json.contains(#""model":"llama-3""#))
        #expect(json.contains(#""temperature":0.8"#))
        #expect(json.contains(#""max_output_tokens":200"#))
        #expect(json.contains(#""top_p":0.95"#))
        #expect(json.contains(#""top_k":50"#))
        #expect(json.contains(#""context_length":4096"#))
        #expect(json.contains(#""reasoning":"high""#))
        #expect(json.contains(#""store":true"#))
    }

    @Test
    func roundTripWithAllFields() throws {
        let original = ChatRequest(
            model: "test-model",
            input: [.text(content: "Test")],
            systemPrompt: "System",
            temperature: 0.5,
            maxOutputTokens: 100,
            topP: 0.9,
            topK: 30,
            minP: 0.01,
            repeatPenalty: 1.1,
            reasoning: "low",
            contextLength: 2048,
            store: false,
            previousResponseID: "prev-456"
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(ChatRequest.self, from: data)

        #expect(decoded.model == "test-model")
        #expect(decoded.systemPrompt == "System")
        #expect(decoded.temperature == 0.5)
        #expect(decoded.maxOutputTokens == 100)
        #expect(decoded.topP == 0.9)
        #expect(decoded.topK == 30)
        #expect(decoded.minP == 0.01)
        #expect(decoded.repeatPenalty == 1.1)
        #expect(decoded.contextLength == 2048)
        #expect(decoded.reasoning == "low")
        #expect(decoded.store == false)
        #expect(decoded.previousResponseID == "prev-456")
    }

    @Test
    func encodingWithImageInput() throws {
        let request = ChatRequest(
            model: "llama-3",
            input: [
                .text(content: "What is this?"),
                .image(dataURL: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==")
            ]
        )

        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = String(data: data, encoding: .utf8)!

        // JSON encoding escapes forward slashes
        #expect(json.contains(#"data:image\/png;base64,iVBORw0KGgo"#))
    }

    @Test
    func inputWithIntegrations() throws {
        let integration = Integration.ephemeralMCP(
            serverLabel: "test-server",
            serverURL: "http://localhost:3000",
            allowedTools: ["tool1", "tool2"]
        )

        let request = ChatRequest(
            model: "llama-3",
            input: [.text(content: "Use a tool")],
            integrations: [integration]
        )

        #expect(request.integrations?.count == 1)

        let data = try JSONEncoder().encode(request)
        let decoded = try JSONDecoder().decode(ChatRequest.self, from: data)

        #expect(decoded.integrations?.count == 1)
    }
}
