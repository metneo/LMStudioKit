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

    @Test
    func withStreamPreservesAllParameters() {
        let request = ChatRequest(
            model: "llama-3",
            input: [.text(content: "test")],
            systemPrompt: "Be helpful",
            temperature: 0.5,
            maxOutputTokens: 100,
            topP: 0.9,
            topK: 40,
            minP: 0.05,
            repeatPenalty: 1.1,
            reasoning: "low",
            contextLength: 4096,
            store: true,
            previousResponseID: "resp-old"
        )
        let streamingRequest = request.withStream(true)
        #expect(streamingRequest.stream == true)
        #expect(streamingRequest.model == "llama-3")
        #expect(streamingRequest.systemPrompt == "Be helpful")
        #expect(streamingRequest.temperature == 0.5)
        #expect(streamingRequest.maxOutputTokens == 100)
        #expect(streamingRequest.topP == 0.9)
        #expect(streamingRequest.topK == 40)
        #expect(streamingRequest.minP == 0.05)
        #expect(streamingRequest.repeatPenalty == 1.1)
        #expect(streamingRequest.reasoning == "low")
        #expect(streamingRequest.contextLength == 4096)
        #expect(streamingRequest.store == true)
        #expect(streamingRequest.previousResponseID == "resp-old")
    }

    @Test
    func encodingSnakeCaseKeys() throws {
        let request = ChatRequest(
            model: "llama-3",
            message: "Test",
            systemPrompt: "System",
            temperature: 0.7,
            maxOutputTokens: 100
        )
        let data = try JSONEncoder().encode(request)
        let json = String(data: data, encoding: .utf8)!
        #expect(json.contains("system_prompt"))
        #expect(json.contains("max_output_tokens"))
        #expect(!json.contains("systemPrompt"))
        #expect(!json.contains("maxOutputTokens"))
    }

    @Test
    func withStoreAndPreviousResponseID() throws {
        let request = ChatRequest(
            model: "llama-3",
            input: [.text(content: "Continue")],
            store: true,
            previousResponseID: "resp-abc"
        )
        #expect(request.store == true)
        #expect(request.previousResponseID == "resp-abc")

        let data = try JSONEncoder().encode(request)
        let json = String(data: data, encoding: .utf8)!
        #expect(json.contains("previous_response_id"))
        #expect(json.contains("resp-abc"))
    }

    @Test
    func withIntegrationsAndHeaders() throws {
        let request = ChatRequest(
            model: "llama-3",
            input: [.text(content: "Use tool")],
            integrations: [.plugin(id: "my-plugin", allowedTools: ["read"])],
            headers: ["X-Custom": "value"]
        )
        #expect(request.integrations?.count == 1)
        #expect(request.headers?["X-Custom"] == "value")
    }
}
