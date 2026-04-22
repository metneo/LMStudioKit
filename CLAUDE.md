# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

LMStudioKit is a Swift library for interacting with the LM Studio REST API, enabling macOS and iOS applications to use local Large Language Models (LLMs).

## Project Structure

```
LMStudioKit/
├── Package.swift              # Swift package manifest
├── README.md                  # Project documentation
├── CLAUDE.md                  # This file
├── Sources/
│   └── LMStudioKit/
│       ├── Client/                 # Client implementation
│       │   ├── LMStudioClient.swift    # Main actor-isolated client
│       │   ├── LMStudioClient+Combine.swift  # Combine publishers
│       │   ├── LMStudioConfig.swift    # Client configuration
│       │   └── LMStudioError.swift     # Error types
│       ├── Core/                    # Core types for chat/streaming
│       │   ├── ChatRequest.swift       # Chat request model
│       │   ├── ChatResponse.swift      # Chat response model
│       │   ├── ChatInput.swift         # Text/image input types
│       │   ├── OutputItem.swift        # Output types (message, tool_call, reasoning)
│       │   ├── Integration.swift        # Plugin/MCP integrations
│       │   ├── ResponseStats.swift      # Token/performance stats
│       │   ├── Streaming.swift         # SSE event types
│       │   └── AnyCodable.swift        # Helper for arbitrary JSON
│       ├── Models/                    # Model management types
│       │   └── ModelTypes.swift        # Model info, load/unload, download types
│       └── Documentation.docc/
│           └── Documentation.md    # DocC documentation
└── Tests/
    └── LMStudioKitTests/
        ├── AnyCodableTests.swift
        ├── ChatInputTests.swift
        ├── ChatRequestTests.swift
        ├── IntegrationTests.swift
        ├── LMStudioConfigTests.swift
        ├── LMStudioErrorTests.swift
        ├── ModelDownloadTests.swift
        ├── ModelInfoTests.swift
        ├── ModelLoadTests.swift
        ├── OutputItemTests.swift
        ├── ResponseStatsTests.swift
        ├── SSEEventTests.swift
        └── LMStudioKitTests.swift  # Main unit tests
```

## Build Commands

- **Build the project:**
  ```bash
  xcodebuild -workspace package.xcworkspace -scheme LMStudioKit -destination 'generic/platform=macOS' build
  ```

- **Run tests:**
  ```bash
  xcodebuild test -workspace package.xcworkspace -scheme LMStudioKit -destination 'generic/platform=macOS'
  ```

## Implementation Notes

### API Design

- Uses Swift actors for thread-safe client implementation
- All network calls are async/await based
- Uses LM Studio native REST API (`/api/v1/*` endpoints only)
- No OpenAI-compatible endpoints

### Native Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/v1/chat` | POST | Chat completions |
| `/api/v1/models` | GET | List available models |
| `/api/v1/models/load` | POST | Load model into memory |
| `/api/v1/models/unload` | POST | Unload model from memory |
| `/api/v1/models/download` | POST | Download a model |
| `/api/v1/models/download/status` | GET | Check download status |

### Key Types

- `LMStudioClient` - Main actor-isolated client
- `LMStudioConfig` - Configuration (baseURL, apiToken)
- `ChatRequest` / `ChatResponse` - Chat models
- `OutputItem` - message, tool_call, reasoning, invalid_tool_call outputs
- `ModelLoadRequest` / `ModelLoadResponse` - Model management
- `LMStudioError` - Error handling

### Adding New Endpoints

When adding new API endpoints:

1. Add request/response types with Codable conformance
2. Add method to `LMStudioClient` actor
3. Include DocC documentation on all public types
4. Update `Documentation.docc/Documentation.md`
5. Add tests in `LMStudioKitTests.swift`

## Documentation

- DocC documentation is in `Documentation.docc/Documentation.md`
- User-facing documentation is in `README.md`
- LM Studio API docs: https://lmstudio.ai/docs/developer/rest