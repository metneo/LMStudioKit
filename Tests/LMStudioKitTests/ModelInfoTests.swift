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

    @Test
    func decodingAllTopLevelFields() throws {
        let json = #"{"type": "llm", "publisher": "meta", "key": "llama-3", "display_name": "Llama 3", "architecture": "llama", "format": "gguf", "size_bytes": 5000000000, "params_string": "8B", "max_context_length": 8192, "description": "A powerful model", "variants": ["Q4_K_M", "Q8_0"], "selected_variant": "Q4_K_M"}"#.data(using: .utf8)!
        let model = try JSONDecoder().decode(ModelInfo.self, from: json)
        #expect(model.publisher == "meta")
        #expect(model.architecture == "llama")
        #expect(model.format == "gguf")
        #expect(model.maxContextLength == 8192)
        #expect(model.description == "A powerful model")
        #expect(model.variants == ["Q4_K_M", "Q8_0"])
        #expect(model.selectedVariant == "Q4_K_M")
    }

    @Test
    func decodingWithReasoningCapabilities() throws {
        let json = #"{"key": "thinking-model", "capabilities": {"vision": false, "trained_for_tool_use": false, "reasoning": {"allowed_options": ["off", "low", "high"], "default": "low"}}}"#.data(using: .utf8)!
        let model = try JSONDecoder().decode(ModelInfo.self, from: json)
        #expect(model.capabilities?.reasoning?.allowedOptions == ["off", "low", "high"])
        #expect(model.capabilities?.reasoning?.default == "low")
    }

    @Test
    func decodingLoadedInstanceFullConfig() throws {
        let json = #"{"key": "llama-3", "loaded_instances": [{"id": "inst-1", "config": {"context_length": 4096, "eval_batch_size": 8, "parallel": 2, "flash_attention": true, "num_experts": 4, "offload_kv_cache_to_gpu": true}}]}"#.data(using: .utf8)!
        let model = try JSONDecoder().decode(ModelInfo.self, from: json)
        let config = model.loadedInstances?.first?.config
        #expect(config?.contextLength == 4096)
        #expect(config?.evalBatchSize == 8)
        #expect(config?.parallel == 2)
        #expect(config?.flashAttention == true)
        #expect(config?.numExperts == 4)
        #expect(config?.offloadKvCacheToGpu == true)
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
