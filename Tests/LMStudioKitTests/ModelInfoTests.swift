import Testing
@testable import LMStudioKit
import Foundation

// MARK: - ModelInfo Tests

struct ModelInfoTests {
    @Test
    func decoding() throws {
        let json = #"{"type": "llm", "key": "llama-3-8b", "display_name": "Llama 3 8B", "size_bytes": 5000000000, "params_string": "8B"}"#.data(using: .utf8)!
        let model = try JSONDecoder().decode(ModelInfo.self, from: json)
        #expect(model.type == "llm")
        #expect(model.key == "llama-3-8b")
        #expect(model.displayName == "Llama 3 8B")
        #expect(model.sizeBytes == 5000000000)
    }

    @Test
    func decodingWithQuantization() throws {
        let json = #"{"key": "llama-3", "quantization": {"name": "Q4_K_M", "bits_per_weight": 4}}"#.data(using: .utf8)!
        let model = try JSONDecoder().decode(ModelInfo.self, from: json)
        #expect(model.quantization?.name == "Q4_K_M")
    }

    @Test
    func decodingWithLoadedInstances() throws {
        let json = #"{"key": "llama-3", "loaded_instances": [{"id": "inst-1", "config": {"context_length": 8192, "flash_attention": true}}]}"#.data(using: .utf8)!
        let model = try JSONDecoder().decode(ModelInfo.self, from: json)
        #expect(model.loadedInstances?.count == 1)
        #expect(model.loadedInstances?[0].config.contextLength == 8192)
    }

    @Test
    func decodingWithCapabilities() throws {
        let json = #"{"key": "llama-3", "capabilities": {"vision": false, "trained_for_tool_use": true}}"#.data(using: .utf8)!
        let model = try JSONDecoder().decode(ModelInfo.self, from: json)
        #expect(model.capabilities?.vision == false)
        #expect(model.capabilities?.trainedForToolUse == true)
    }
}

// MARK: - ModelListResponse Tests

struct ModelListResponseTests {
    @Test
    func decoding() throws {
        let json = #"{"models": [{"key": "model-1"}, {"key": "model-2"}]}"#.data(using: .utf8)!
        let response = try JSONDecoder().decode(ModelListResponse.self, from: json)
        #expect(response.models?.count == 2)
    }

    @Test
    func decodingEmptyModels() throws {
        let json = #"{"models": []}"#.data(using: .utf8)!
        let response = try JSONDecoder().decode(ModelListResponse.self, from: json)
        #expect(response.models?.isEmpty == true)
    }
}
