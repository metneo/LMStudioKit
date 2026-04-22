import Testing
@testable import LMStudioKit
import Foundation

// MARK: - ModelLoadRequest Tests

struct ModelLoadRequestTests {
    @Test
    func basicInitialization() {
        let request = ModelLoadRequest(model: "llama-3")
        #expect(request.model == "llama-3")
        #expect(request.contextLength == nil)
    }

    @Test
    func fullInitialization() {
        let request = ModelLoadRequest(
            model: "llama-3",
            contextLength: 4096,
            evalBatchSize: 8,
            flashAttention: true,
            offloadKvCacheToGpu: true
        )
        #expect(request.contextLength == 4096)
        #expect(request.flashAttention == true)
    }

    @Test
    func encodingAndDecoding() throws {
        let request = ModelLoadRequest(model: "llama-3", contextLength: 8192)
        let decoded = try JSONDecoder().decode(ModelLoadRequest.self, from: try JSONEncoder().encode(request))
        #expect(decoded.model == request.model)
        #expect(decoded.contextLength == request.contextLength)
    }
}

// MARK: - LoadConfig Tests

struct LoadConfigTests {
    @Test
    func decoding() throws {
        let json = #"{"context_length": 4096, "eval_batch_size": 8, "flash_attention": true}"#.data(using: .utf8)!
        let config = try JSONDecoder().decode(LoadConfig.self, from: json)
        #expect(config.contextLength == 4096)
        #expect(config.flashAttention == true)
    }
}

// MARK: - ModelLoadResponse Tests

struct ModelLoadResponseTests {
    @Test
    func decoding() throws {
        let json = #"{"type": "llm", "instance_id": "inst-123", "load_time_seconds": 2.5, "status": "loaded"}"#.data(using: .utf8)!
        let response = try JSONDecoder().decode(ModelLoadResponse.self, from: json)
        #expect(response.instanceId == "inst-123")
        #expect(response.status == "loaded")
    }
}

// MARK: - ModelUnloadRequest Tests

struct ModelUnloadRequestTests {
    @Test
    func basicInitialization() {
        let request = ModelUnloadRequest(instanceId: "inst-123")
        #expect(request.instanceId == "inst-123")
    }

    @Test
    func encodingAndDecoding() throws {
        let request = ModelUnloadRequest(instanceId: "inst-456")
        let decoded = try JSONDecoder().decode(ModelUnloadRequest.self, from: try JSONEncoder().encode(request))
        #expect(decoded.instanceId == "inst-456")
    }
}

// MARK: - ModelUnloadResponse Tests

struct ModelUnloadResponseTests {
    @Test
    func decoding() throws {
        let json = #"{"instance_id": "inst-123"}"#.data(using: .utf8)!
        let response = try JSONDecoder().decode(ModelUnloadResponse.self, from: json)
        #expect(response.instanceId == "inst-123")
    }
}

// MARK: - Additional ModelLoadRequest Tests

struct ModelLoadRequestAdditionalTests {
    @Test
    func allFieldsEncoding() throws {
        let request = ModelLoadRequest(
            model: "llama-3",
            contextLength: 4096,
            evalBatchSize: 8,
            flashAttention: true,
            numExperts: 4,
            offloadKvCacheToGpu: true,
            echoLoadConfig: true
        )
        let data = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        #expect(json["context_length"] as? Int == 4096)
        #expect(json["num_experts"] as? Int == 4)
        #expect(json["offload_kv_cache_to_gpu"] as? Bool == true)
        #expect(json["echo_load_config"] as? Bool == true)
    }

    @Test
    func encodingKeysAreSnakeCase() throws {
        let request = ModelLoadRequest(model: "m", contextLength: 1024, flashAttention: true)
        let data = try JSONEncoder().encode(request)
        let json = String(data: data, encoding: .utf8)!
        #expect(json.contains("context_length"))
        #expect(json.contains("flash_attention"))
        #expect(!json.contains("contextLength"))
    }
}

// MARK: - Additional ModelLoadResponse Tests

struct ModelLoadResponseAdditionalTests {
    @Test
    func decodingWithLoadConfig() throws {
        let json = #"{"status": "loaded", "instance_id": "inst-1", "load_time_seconds": 2.5, "type": "llm", "load_config": {"context_length": 4096, "flash_attention": true}}"#.data(using: .utf8)!
        let response = try JSONDecoder().decode(ModelLoadResponse.self, from: json)
        #expect(response.loadConfig?.contextLength == 4096)
        #expect(response.loadConfig?.flashAttention == true)
        #expect(response.loadTimeSeconds == 2.5)
        #expect(response.type == "llm")
    }
}
