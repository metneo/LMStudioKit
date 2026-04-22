import Foundation

// MARK: - Model Types

/// A single model instance that is currently loaded.
///
/// ## See Also
///
/// - <https://lmstudio.ai/docs/developer/rest/list#loaded-instances>
public struct LoadedInstance: Codable, Sendable {
    /// The unique identifier for this loaded instance.
    public let id: String

    /// Configuration for this loaded instance.
    public let config: LoadedInstanceConfig
}

/// Configuration for a loaded model instance.
public struct LoadedInstanceConfig: Codable, Sendable {
    /// The context length for this instance.
    public let contextLength: Int

    /// The evaluation batch size (optional).
    public let evalBatchSize: Int?

    /// Number of parallel requests (optional).
    public let parallel: Int?

    /// Whether flash attention is enabled (optional).
    public let flashAttention: Bool?

    /// Number of experts for MoE models (optional).
    public let numExperts: Int?

    /// Whether KV cache is offloaded to GPU (optional).
    public let offloadKvCacheToGpu: Bool?

    enum CodingKeys: String, CodingKey {
        case contextLength = "context_length"
        case evalBatchSize = "eval_batch_size"
        case parallel
        case flashAttention = "flash_attention"
        case numExperts = "num_experts"
        case offloadKvCacheToGpu = "offload_kv_cache_to_gpu"
    }
}

/// Quantization information for a model.
public struct QuantizationInfo: Codable, Sendable {
    /// The quantization method name (optional).
    public let name: String?

    /// Bits per weight (optional).
    public let bitsPerWeight: Double?

    enum CodingKeys: String, CodingKey {
        case name
        case bitsPerWeight = "bits_per_weight"
    }
}

/// Reasoning capabilities of a model.
public struct ReasoningCapabilities: Codable, Sendable {
    /// Available reasoning options.
    public let allowedOptions: [String]

    /// Default reasoning option.
    public let `default`: String

    enum CodingKeys: String, CodingKey {
        case allowedOptions = "allowed_options"
        case `default`
    }
}

/// Capabilities of a model.
public struct ModelCapabilities: Codable, Sendable {
    /// Whether the model supports vision.
    public let vision: Bool

    /// Whether the model is trained for tool use.
    public let trainedForToolUse: Bool

    /// Reasoning capabilities.
    public let reasoning: ReasoningCapabilities?

    enum CodingKeys: String, CodingKey {
        case vision
        case trainedForToolUse = "trained_for_tool_use"
        case reasoning
    }
}

/// Information about an available model.
///
/// ``ModelInfo`` contains details about models available on the server,
/// including key, display name, size, quantization, and loaded instances.
///
/// ## See Also
///
/// - <https://lmstudio.ai/docs/developer/rest/list#model-info>
public struct ModelInfo: Codable, Sendable {
    /// The type of model ("llm" or "embedding").
    public let type: String?

    /// The publisher of the model.
    public let publisher: String?

    /// The unique key/path identifier for the model.
    public let key: String?

    /// The display name for the model.
    public let displayName: String?

    /// The model architecture (null for embedding models).
    public let architecture: String?

    /// Quantization information.
    public let quantization: QuantizationInfo?

    /// The size of the model in bytes.
    public let sizeBytes: Int64?

    /// Parameter count as a string (e.g., "7B").
    public let paramsString: String?

    /// Currently loaded instances of this model.
    public let loadedInstances: [LoadedInstance]?

    /// Maximum context length supported by the model.
    public let maxContextLength: Int?

    /// The model format (e.g., "gguf", "mlx").
    public let format: String?

    /// Model capabilities (not present for embedding models).
    public let capabilities: ModelCapabilities?

    /// Model description (null for embedding models).
    public let description: String?

    /// Available variants of the model.
    public let variants: [String]?

    /// The currently selected variant.
    public let selectedVariant: String?

    enum CodingKeys: String, CodingKey {
        case type, publisher, key, architecture, quantization, format, capabilities, description, variants
        case displayName = "display_name"
        case sizeBytes = "size_bytes"
        case paramsString = "params_string"
        case loadedInstances = "loaded_instances"
        case maxContextLength = "max_context_length"
        case selectedVariant = "selected_variant"
    }
}

/// The response containing a list of available models.
public struct ModelListResponse: Codable, Sendable {
    /// The list of available models.
    public let models: [ModelInfo]?
}

// MARK: - Model Load/Unload Types

/// Configuration for a loaded model.
///
/// ## See Also
///
/// - <https://lmstudio.ai/docs/developer/rest/load#load-config>
public struct LoadConfig: Codable, Sendable {
    /// The context length for the loaded model.
    public let contextLength: Int?

    /// The evaluation batch size (optional).
    public let evalBatchSize: Int?

    /// Whether flash attention is enabled (optional).
    public let flashAttention: Bool?

    /// Number of experts for MoE models (optional).
    public let numExperts: Int?

    /// Whether KV cache is offloaded to GPU (optional).
    public let offloadKvCacheToGpu: Bool?

    enum CodingKeys: String, CodingKey {
        case contextLength = "context_length"
        case evalBatchSize = "eval_batch_size"
        case flashAttention = "flash_attention"
        case numExperts = "num_experts"
        case offloadKvCacheToGpu = "offload_kv_cache_to_gpu"
    }
}

/// A request to load a model into memory.
///
/// ## See Also
///
/// - <https://lmstudio.ai/docs/developer/rest/load>
public struct ModelLoadRequest: Codable, Sendable {
    /// The model identifier to load.
    public let model: String

    /// Optional context length to specify for the model.
    public let contextLength: Int?

    /// The evaluation batch size (optional).
    public let evalBatchSize: Int?

    /// Whether to enable flash attention (optional).
    public let flashAttention: Bool?

    /// Number of experts for MoE models (optional).
    public let numExperts: Int?

    /// Whether to offload KV cache to GPU (optional).
    public let offloadKvCacheToGpu: Bool?

    /// Whether to echo the load config in the response (optional).
    public let echoLoadConfig: Bool?

    /// Creates a new model load request.
    ///
    /// - Parameters:
    ///   - model: The model identifier to load.
    ///   - contextLength: Optional context length override.
    ///   - evalBatchSize: Optional evaluation batch size.
    ///   - flashAttention: Whether to enable flash attention.
    ///   - numExperts: Number of experts for MoE models.
    ///   - offloadKvCacheToGpu: Whether to offload KV cache to GPU.
    ///   - echoLoadConfig: Whether to echo load config in response.
    public init(
        model: String,
        contextLength: Int? = nil,
        evalBatchSize: Int? = nil,
        flashAttention: Bool? = nil,
        numExperts: Int? = nil,
        offloadKvCacheToGpu: Bool? = nil,
        echoLoadConfig: Bool? = nil
    ) {
        self.model = model
        self.contextLength = contextLength
        self.evalBatchSize = evalBatchSize
        self.flashAttention = flashAttention
        self.numExperts = numExperts
        self.offloadKvCacheToGpu = offloadKvCacheToGpu
        self.echoLoadConfig = echoLoadConfig
    }

    enum CodingKeys: String, CodingKey {
        case model
        case contextLength = "context_length"
        case evalBatchSize = "eval_batch_size"
        case flashAttention = "flash_attention"
        case numExperts = "num_experts"
        case offloadKvCacheToGpu = "offload_kv_cache_to_gpu"
        case echoLoadConfig = "echo_load_config"
    }
}

/// The response from a model load request.
///
/// ## See Also
///
/// - <https://lmstudio.ai/docs/developer/rest/load#response>
public struct ModelLoadResponse: Codable, Sendable {
    /// The type of model ("llm" or "embedding").
    public let type: String?

    /// The unique instance identifier for the loaded model.
    public let instanceId: String?

    /// The time taken to load the model in seconds.
    public let loadTimeSeconds: Double?

    /// The status of the operation (e.g., "loaded").
    public let status: String

    /// The load configuration used (only present if echo_load_config was true).
    public let loadConfig: LoadConfig?

    enum CodingKeys: String, CodingKey {
        case type
        case instanceId = "instance_id"
        case loadTimeSeconds = "load_time_seconds"
        case status
        case loadConfig = "load_config"
    }
}

/// A request to unload a model from memory.
///
/// ## See Also
///
/// - <https://lmstudio.ai/docs/developer/rest/unload>
public struct ModelUnloadRequest: Codable, Sendable {
    /// The instance identifier to unload.
    public let instanceId: String

    /// Creates a new model unload request.
    ///
    /// - Parameter instanceId: The instance identifier to unload.
    public init(instanceId: String) {
        self.instanceId = instanceId
    }

    enum CodingKeys: String, CodingKey {
        case instanceId = "instance_id"
    }
}

/// The response from a model unload request.
public struct ModelUnloadResponse: Codable, Sendable {
    /// The instance identifier that was unloaded.
    public let instanceId: String?

    enum CodingKeys: String, CodingKey {
        case instanceId = "instance_id"
    }
}

// MARK: - Download Types

/// A request to download a model.
///
/// ## See Also
///
/// - <https://lmstudio.ai/docs/developer/rest/download>
public struct ModelDownloadRequest: Codable, Sendable {
    /// The model identifier or Hugging Face path to download.
    public let model: String

    /// Quantization option (optional).
    public let quantization: String?

    /// Creates a new model download request.
    ///
    /// - Parameters:
    ///   - model: The model identifier or Hugging Face path to download.
    ///   - quantization: Optional quantization method.
    public init(model: String, quantization: String? = nil) {
        self.model = model
        self.quantization = quantization
    }

    enum CodingKeys: String, CodingKey {
        case model
        case quantization
    }
}

/// The response from a model download request.
///
/// ## See Also
///
/// - <https://lmstudio.ai/docs/developer/rest/download#response>
public struct ModelDownloadResponse: Codable, Sendable {
    /// The unique job identifier for this download.
    public let jobId: String?

    /// The download status.
    public let status: String

    /// Total size in bytes.
    public let totalSizeBytes: Int64?

    /// ISO 8601 timestamp when download started.
    public let startedAt: String?

    /// ISO 8601 timestamp when download completed (if finished).
    public let completedAt: String?

    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case status
        case totalSizeBytes = "total_size_bytes"
        case startedAt = "started_at"
        case completedAt = "completed_at"
    }
}

/// The status of a model download.
///
/// ## See Also
///
/// - <https://lmstudio.ai/docs/developer/rest/download-status>
public struct ModelDownloadStatusResponse: Codable, Sendable {
    /// The unique job identifier.
    public let jobId: String?

    /// The download status.
    public let status: String

    /// Total size in bytes.
    public let totalSizeBytes: Int64?

    /// Number of bytes downloaded.
    public let downloadedBytes: Int64?

    /// ISO 8601 timestamp when download started.
    public let startedAt: String?

    /// ISO 8601 timestamp when download completed.
    public let completedAt: String?

    /// Download speed in bytes per second.
    public let speedBytesPerSecond: Double?

    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case status
        case totalSizeBytes = "total_size_bytes"
        case downloadedBytes = "downloaded_bytes"
        case startedAt = "started_at"
        case completedAt = "completed_at"
        case speedBytesPerSecond = "speed_bytes_per_second"
    }
}