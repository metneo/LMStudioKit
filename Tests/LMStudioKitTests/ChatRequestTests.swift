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
}
