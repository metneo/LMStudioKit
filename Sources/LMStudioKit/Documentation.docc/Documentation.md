# ``LMStudioKit``

A Swift client library for interacting with the LM Studio REST API.

## Overview

LMStudioKit provides a native Swift interface to connect to LM Studio servers, enabling you to leverage local Large Language Models (LLMs) in your macOS and iOS applications. The library uses LM Studio's native REST API (`/api/v1/*`).

## Getting Started

### Creating a Client

Create an ``LMStudioClient`` to connect to your LM Studio server:

```swift
import LMStudioKit

// Connect to localhost (default port 1234)
let client = LMStudioClient()

// Connect to a custom URL with authentication
let config = LMStudioConfig(
    baseURL: URL(string: "http://localhost:1234")!,
    apiToken: "your-api-token"
)
let client = LMStudioClient(config: config)
```

### Chat Completions

Send a chat request and receive model-generated responses:

```swift
import LMStudioKit

let client = LMStudioClient()

let request = ChatRequest(
    model: "llama-3-8b",
    message: "Explain quantum computing in simple terms.",
    temperature: 0.7,
    maxOutputTokens: 500
)

let response = try await client.chat(request: request)
if case .message(let content) = response.output?.first {
    print(content)
}
```

### Chat with Multiple Inputs

Send messages with multiple content types (text and images):

```swift
let request = ChatRequest(
    model: "llama-3-8b",
    input: [
        .text(content: "What is in this image?"),
        .image(dataURL: "data:image/png;base64,...")
    ]
)

let response = try await client.chat(request: request)
```

### Streaming Chat

Receive responses incrementally as they're generated with detailed event types:

```swift
let request = ChatRequest(
    model: "llama-3-8b",
    message: "Tell me a long story",
    temperature: 0.7
)

for try await event in client.chatStream(request: request) {
    switch event {
    case .messageDelta(let data):
        print(data.content ?? "", terminator: "")
    case .reasoningDelta(let data):
        print("[Reasoning: \(data.content ?? "")]", terminator: "")
    case .toolCallStart(let data):
        print("Calling tool: \(data.tool ?? "")")
    case .toolCallSuccess(let data):
        print("Tool result: \(data.output ?? "")")
    case .chatEnd(let data):
        print("\nDone! \(data.result?.stats?.totalOutputTokens ?? 0) tokens generated")
    case .error(let data):
        print("Error: \(data.error?.message ?? "unknown")")
    default:
        break
    }
}
```

### Tool Use

Enable tool calling via MCP integrations or plugins:

```swift
// Enable an MCP server integration
let integration = Integration.ephemeralMCP(
    serverLabel: "weather-api",
    serverURL: "http://localhost:3000/mcp",
    allowedTools: ["get_weather", "get_forecast"]
)

let request = ChatRequest(
    model: "llama-3-8b",
    message: "What's the weather in San Francisco?",
    integrations: [integration]
)

for try await event in client.chatStream(request: request) {
    switch event {
    case .toolCallStart(let data):
        print("Calling tool: \(data.tool ?? "")")

    case .toolCallArguments(let data):
        if let args = data.arguments {
            print("Arguments: \(args)")
        }

    case .toolCallSuccess(let data):
        print("Tool \(data.tool ?? "") returned: \(data.output ?? "")")

    case .toolCallFailure(let data):
        print("Tool failed: \(data.reason ?? "unknown reason")")

    case .messageDelta(let data):
        print(data.content ?? "", terminator: "")

    default:
        break
    }
}
```

For plugins, use the ``Integration/plugin`` case:

```swift
let pluginIntegration = Integration.plugin(
    id: "my-plugin-id",
    allowedTools: ["search", "lookup"]
)

let request = ChatRequest(
    model: "llama-3-8b",
    message: "Search for recent news about Swift",
    integrations: [pluginIntegration]
)
```

### Listing Models

Discover available models on the server:

```swift
let models = try await client.listModels()
for model in models.models ?? [] {
    print("\(model.key ?? model.displayName ?? "unknown")")
}
```

### Loading and Unloading Models

Load models into memory before inference:

```swift
// Load a model
let loadRequest = ModelLoadRequest(
    model: "llama-3-8b",
    contextLength: 4096
)
let loadResponse = try await client.loadModel(request: loadRequest)
print(loadResponse.status)

// When done, unload to free memory
let unloadRequest = ModelUnloadRequest(instanceId: loadResponse.instanceId ?? "")
let unloadResponse = try await client.unloadModel(request: unloadRequest)
print(unloadResponse.instanceId)
```

### Downloading Models

Download models from Hugging Face:

```swift
let downloadRequest = ModelDownloadRequest(
    model: "lmstudio-community/llama-3-8b",
    quantization: "Q4_K_M"
)
let downloadResponse = try await client.downloadModel(request: downloadRequest)
print("Job ID: \(downloadResponse.jobId ?? "unknown")")
print("Status: \(downloadResponse.status)")

// Check download status
let status = try await client.downloadStatus(jobId: downloadResponse.jobId ?? "")
print("Downloaded: \(status.downloadedBytes ?? 0) / \(status.totalSizeBytes ?? 0)")
```

## Topics

### Client

- <doc:GettingStarted>
- ``LMStudioConfig``
- ``LMStudioClient``

### Chat

- ``ChatInput``
- ``ChatRequest``
- ``ChatResponse``
- ``OutputItem``
- ``Integration``

### Tools

- ``Integration``
- ``OutputItem/toolCall``
- ``OutputItem/invalidToolCall``
- ``SSEEvent/toolCallStart``
- ``SSEEvent/toolCallArguments``
- ``SSEEvent/toolCallSuccess``
- ``SSEEvent/toolCallFailure``

### Models

- ``ModelInfo``
- ``ModelListResponse``
- ``ModelLoadRequest``
- ``ModelLoadResponse``
- ``ModelUnloadRequest``
- ``ModelUnloadResponse``
- ``ModelDownloadRequest``
- ``ModelDownloadResponse``
- ``ModelDownloadStatusResponse``

### Streaming Events

The ``SSEEvent`` enum provides all streaming event types:

- ``SSEEvent/chatStart`` - Chat session started
- ``SSEEvent/modelLoadStart`` - Model loading started
- ``SSEEvent/modelLoadProgress`` - Model loading progress
- ``SSEEvent/modelLoadEnd`` - Model loading completed
- ``SSEEvent/promptProcessingStart`` - Prompt processing started
- ``SSEEvent/promptProcessingProgress`` - Prompt processing progress
- ``SSEEvent/promptProcessingEnd`` - Prompt processing completed
- ``SSEEvent/reasoningStart`` - Reasoning phase started
- ``SSEEvent/reasoningDelta`` - Reasoning content delta
- ``SSEEvent/reasoningEnd`` - Reasoning phase completed
- ``SSEEvent/toolCallStart`` - Tool call started
- ``SSEEvent/toolCallArguments`` - Tool call arguments
- ``SSEEvent/toolCallSuccess`` - Tool call succeeded
- ``SSEEvent/toolCallFailure`` - Tool call failed
- ``SSEEvent/messageStart`` - Message output started
- ``SSEEvent/messageDelta`` - Message content delta
- ``SSEEvent/messageEnd`` - Message output completed
- ``SSEEvent/error`` - Error event
- ``SSEEvent/chatEnd`` - Chat session completed

### Response Statistics

- ``ResponseStats``

### Errors

- ``LMStudioError``

### Supporting Types

- ``AnyCodable``

## See Also

- [LM Studio Website](https://lmstudio.ai)
- [LM Studio REST API Documentation](https://lmstudio.ai/docs/developer/rest)
- [LM Studio Streaming Events Documentation](https://lmstudio.ai/docs/developer/rest/streaming-events)