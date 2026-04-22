import Darwin
import Foundation
import Testing

@testable import LMStudioKit

private enum LMStudioIntegrationTestEnvironment {
    static let isEndpointReachable: Bool = {
        canConnectToLocalhost(port: 1234)
    }()

    private static func canConnectToLocalhost(port: UInt16) -> Bool {
        var hints = addrinfo(
            ai_flags: 0,
            ai_family: AF_UNSPEC,
            ai_socktype: SOCK_STREAM,
            ai_protocol: IPPROTO_TCP,
            ai_addrlen: 0,
            ai_canonname: nil,
            ai_addr: nil,
            ai_next: nil
        )

        var result: UnsafeMutablePointer<addrinfo>?
        let status = "localhost".withCString { hostPointer in
            String(port).withCString { servicePointer in
                getaddrinfo(hostPointer, servicePointer, &hints, &result)
            }
        }

        guard status == 0, let start = result else {
            return false
        }

        defer { freeaddrinfo(start) }

        var current = start
        while true {
            let socketDescriptor = socket(
                current.pointee.ai_family, current.pointee.ai_socktype, current.pointee.ai_protocol)
            if socketDescriptor >= 0 {
                defer { close(socketDescriptor) }

                if connect(socketDescriptor, current.pointee.ai_addr, current.pointee.ai_addrlen)
                    == 0
                {
                    return true
                }
            }

            guard let next = current.pointee.ai_next else {
                break
            }

            current = next
        }

        return false
    }
}

// MARK: - LMStudioClient Integration Tests
//
// These tests make real network requests to an LM Studio server running at
// http://localhost:1234 with an empty API token.
//
// Run with: swift test

@Suite(.enabled(if: LMStudioIntegrationTestEnvironment.isEndpointReachable))
struct LMStudioClientIntegrationTests {
    private let LM_STUDIO_HOST = "http://localhost:1234"

    private var baseURL: URL {
        URL(string: LM_STUDIO_HOST)!
    }

    private var client: LMStudioClient {
        LMStudioClient(config: LMStudioConfig(baseURL: baseURL, apiToken: ""))
    }

    // MARK: - List Models

    @Test
    func listModelsRealAPI() async throws {
        let response = try await client.listModels()
        #expect(response.models != nil)
    }

    // MARK: - Chat Completion

    @Test
    func chatCompletionRealAPI() async throws {
        let request = ChatRequest(
            model: "liquid/lfm2.5-1.2b",
            message: "Say 'hello' in exactly one word",
            temperature: 0.0,
            maxOutputTokens: 10
        )

        let response = try await client.chat(request: request)
        #expect(response.output != nil)
        #expect(response.output?.isEmpty == false)
    }

    // MARK: - Chat with System Prompt

    @Test
    func chatWithSystemPromptRealAPI() async throws {
        let request = ChatRequest(
            model: "liquid/lfm2.5-1.2b",
            message: "What is 2+2?",
            systemPrompt: "You are a math assistant. Answer only with the number.",
            temperature: 0.0,
            maxOutputTokens: 5
        )

        let response = try await client.chat(request: request)
        #expect(response.output?.first != nil)
    }

    // MARK: - Streaming Chat

    @Test
    func streamingChatRealAPI() async throws {
        let request = ChatRequest(
            model: "liquid/lfm2.5-1.2b",
            message: "Count from 1 to 3",
            temperature: 0.0,
            maxOutputTokens: 50
        )

        var eventCount = 0
        var receivedText = false

        // Use a Task to call actor-isolated method
        let events = await client.chatStream(request: request)
        for try await event in events {
            eventCount += 1
            if case .messageDelta = event {
                receivedText = true
            }
        }

        #expect(eventCount > 0)
        #expect(receivedText == true)
    }

    // MARK: - Streaming Chat with Reasoning

    @Test
    func streamingChatWithReasoningRealAPI() async throws {
        let request = ChatRequest(
            model: "liquid/lfm2.5-1.2b",
            message: "Think about why the sky is blue",
            temperature: 0.7,
            maxOutputTokens: 200
        )

        var hasReasoning = false
        var hasMessage = false

        // Use a Task to call actor-isolated method
        let events = await client.chatStream(request: request)
        for try await event in events {
            if case .reasoningDelta = event {
                hasReasoning = true
            }
            if case .messageDelta = event {
                hasMessage = true
            }
        }

        // At least one of reasoning or message should be present
        #expect(hasReasoning || hasMessage)
    }

    // MARK: - Model Load

    @Test
    func loadModelRealAPI() async throws {
        // First list models to find an available one
        let modelsResponse = try await client.listModels()
        guard let availableModel = modelsResponse.models?.first else {
            throw SkipPMK("No models available to load")
        }

        let modelKey = availableModel.key ?? availableModel.displayName ?? ""
        guard !modelKey.isEmpty else {
            throw SkipPMK("Model has no key or displayName")
        }

        let loadRequest = ModelLoadRequest(model: modelKey)
        let loadResponse = try await client.loadModel(request: loadRequest)

        #expect(loadResponse.instanceId != nil)
        #expect(!loadResponse.status.isEmpty)

        // Cleanup: unload the model
        if let instanceId = loadResponse.instanceId {
            let unloadRequest = ModelUnloadRequest(instanceId: instanceId)
            _ = try await client.unloadModel(request: unloadRequest)
        }
    }
}

// MARK: - SkipPMK Helper

struct SkipPMK: Error, CustomStringConvertible {
    let message: String
    init(_ message: String) {
        self.message = message
    }
    var description: String { message }
}
