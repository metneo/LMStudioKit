# LMStudioKit

A Swift client library for interacting with LM Studio's native REST API, enabling native macOS and iOS applications to leverage local Large Language Models (LLMs).

## Features

- **Native REST API** - Uses LM Studio's `/api/v1/*` endpoints directly
- **Async/Await** - Modern Swift concurrency for seamless asynchronous operations
- **Cross-Platform** - Supports macOS 12+ and iOS 15+
- **Actor-Safe** - Thread-safe client implementation using Swift actors
- **Streaming Support** - SSE-based streaming with detailed event types
- **Tool Support** - Full support for tool/function calling via MCP integrations
- **Combine Publishers** - Reactive extensions for Combine-based workflows

## Requirements

- Swift 6.0+ (default manifest)
- Swift 5.9+ (legacy manifest via `Package@swift-5.9.swift`)
- macOS 12.0+ or iOS 15.0+
- LM Studio running locally (default: `http://localhost:1234`)

## Installation

### Swift Package Manager

Add LMStudioKit to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/metneo/LMStudioKit.git", from: "1.0.0")
]
```

Or in Xcode, go to **File > Add Package Dependencies** and enter the repository URL.

## Quick Start

```swift
import LMStudioKit

// Create a client
let client = LMStudioClient()

// Send a chat request
let request = ChatRequest(
    model: "llama-3-8b",
    message: "Hello! Explain Swift in simple terms.",
    temperature: 0.7
)

let response = try await client.chat(request: request)
if case .message(let content) = response.output?.first {
    print(content)
}
```

## Usage

### Configuration

```swift
// Default: http://localhost:1234
let client = LMStudioClient()

// Custom URL and API token
let config = LMStudioConfig(
    baseURL: URL(string: "http://192.168.1.100:1234")!,
    apiToken: "optional-token"
)
let client = LMStudioClient(config: config)
```

### Chat Completions

```swift
let request = ChatRequest(
    model: "llama-3-8b",
    message: "What is quantum computing?",
    systemPrompt: "You are a helpful physics tutor.",
    temperature: 0.7,
    maxOutputTokens: 500
)
let response = try await client.chat(request: request)
```

### Chat with Multiple Inputs (Text + Images)

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
        print("\nDone! \(data.result?.stats?.totalOutputTokens ?? 0) tokens")
    case .error(let data):
        print("Error: \(data.error?.message ?? "unknown")")
    default:
        break
    }
}
```

### Combine Publishers

```swift
import LMStudioKit
import Combine

let client = LMStudioClient()
let request = ChatRequest(
    model: "llama-3-8b",
    message: "Hello!"
)

// Publish the streaming response as a Combine publisher
let publisher = client.chatPublisher(for: request)

let cancellable = publisher.sink(
    receiveCompletion: { completion in
        if case .failure(let error) = completion {
            print("Error: \(error)")
        }
    },
    receiveValue: { event in
        if case .messageDelta(let data) = event {
            print(data.content ?? "", terminator: "")
        }
    }
)
```

### List Available Models

```swift
let models = try await client.listModels()
for model in models.models ?? [] {
    print("\(model.key ?? model.displayName ?? "unknown")")
}
```

### Model Management

```swift
// Load a model into memory
let loadRequest = ModelLoadRequest(
    model: "llama-3-8b",
    contextLength: 4096
)
let loadResponse = try await client.loadModel(request: loadRequest)
print("Instance ID: \(loadResponse.instanceId ?? "")")

// Unload when done
let unloadRequest = ModelUnloadRequest(instanceId: loadResponse.instanceId ?? "")
try await client.unloadModel(request: unloadRequest)
```

### Download Models

```swift
// Start a download
let downloadRequest = ModelDownloadRequest(
    model: "lmstudio-community/llama-3-8b",
    quantization: "Q4_K_M"
)
let downloadResponse = try await client.downloadModel(request: downloadRequest)
print("Job ID: \(downloadResponse.jobId ?? "")")

// Check download status
let status = try await client.downloadStatus(jobId: downloadResponse.jobId ?? "")
print("Downloaded: \(status.downloadedBytes ?? 0) / \(status.totalSizeBytes ?? 0)")
```

### Tool Use with MCP Integrations

Enable tool calling via MCP (Model Context Protocol) integrations:

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

## API Endpoints

| Endpoint                        | Method | Description                         |
| ------------------------------- | ------ | ----------------------------------- |
| `/api/v1/chat`                  | POST   | Chat completions (single & streaming) |
| `/api/v1/models`                | GET    | List available models               |
| `/api/v1/models/load`          | POST   | Load model into memory              |
| `/api/v1/models/unload`        | POST   | Unload model from memory            |
| `/api/v1/models/download`       | POST   | Download a model                    |
| `/api/v1/models/download/status`| GET    | Check download status               |

## Streaming Events

The `chatStream` method provides detailed events for each stage of the streaming response:

| Event                                                               | Description            |
| ------------------------------------------------------------------- | ---------------------- |
| `chatStart` / `chatEnd`                                              | Chat session lifecycle  |
| `modelLoadStart` / `modelLoadProgress` / `modelLoadEnd`              | Model loading stages   |
| `promptProcessingStart` / `promptProcessingProgress` / `promptProcessingEnd` | Prompt processing  |
| `reasoningStart` / `reasoningDelta` / `reasoningEnd`                | Reasoning phase        |
| `messageStart` / `messageDelta` / `messageEnd`                       | Message output         |
| `toolCallStart` / `toolCallArguments` / `toolCallSuccess` / `toolCallFailure` | Tool calls    |
| `error`                                                              | Error events           |

## Error Handling

```swift
do {
    let response = try await client.chat(request: request)
} catch let error as LMStudioError {
    switch error {
    case .invalidResponse:
        print("Server returned an invalid response")
    case .httpError(let statusCode, _):
        print("HTTP error: \(statusCode)")
    case .streamingError(let message):
        print("Streaming error: \(message)")
    }
}
```

## Documentation

- [LM Studio REST API Documentation](https://lmstudio.ai/docs/developer/rest)
- [Full API Documentation](Sources/LMStudioKit/Documentation.docc/Documentation.md)

## License

MIT License - see LICENSE file for details.
