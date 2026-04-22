import Testing
@testable import LMStudioKit
import Foundation

// MARK: - Integration Tests

struct IntegrationTests {
    @Test
    func pluginEncoding() throws {
        let integration = Integration.plugin(id: "my-plugin", allowedTools: ["tool1", "tool2"])
        let json = String(data: try JSONEncoder().encode(integration), encoding: .utf8)!
        #expect(json.contains("\"type\":\"plugin\""))
        #expect(json.contains("\"id\":\"my-plugin\""))
    }

    @Test
    func pluginWithNilAllowedTools() throws {
        let integration = Integration.plugin(id: "my-plugin", allowedTools: nil)
        let json = String(data: try JSONEncoder().encode(integration), encoding: .utf8)!
        #expect(json.contains("\"type\":\"plugin\""))
        #expect(!json.contains("allowed_tools"))
    }

    @Test
    func ephemeralMCPEncoding() throws {
        let integration = Integration.ephemeralMCP(
            serverLabel: "my-server",
            serverURL: "http://localhost:8080",
            allowedTools: ["tool1"]
        )
        let json = String(data: try JSONEncoder().encode(integration), encoding: .utf8)!
        #expect(json.contains("\"type\":\"ephemeral_mcp\""))
        #expect(json.contains("\"server_label\":\"my-server\""))
    }

    @Test
    func pluginDecoding() throws {
        let json = #"{"type": "plugin", "id": "test-plugin", "allowed_tools": ["read", "write"]}"#.data(using: .utf8)!
        let integration = try JSONDecoder().decode(Integration.self, from: json)
        if case .plugin(let id, let allowedTools) = integration {
            #expect(id == "test-plugin")
            #expect(allowedTools == ["read", "write"])
        } else {
            Issue.record("Expected plugin integration")
        }
    }

    @Test
    func ephemeralMCPDecoding() throws {
        let json = #"{"type": "ephemeral_mcp", "server_label": "weather", "server_url": "http://localhost:3000/mcp", "allowed_tools": ["get_weather"]}"#.data(using: .utf8)!
        let integration = try JSONDecoder().decode(Integration.self, from: json)
        if case .ephemeralMCP(let label, let url, _) = integration {
            #expect(label == "weather")
            #expect(url == "http://localhost:3000/mcp")
        } else {
            Issue.record("Expected ephemeral MCP")
        }
    }

    @Test
    func unknownTypeThrows() {
        let json = #"{"type": "unknown_integration"}"#.data(using: .utf8)!
        #expect(throws: (any Error).self) {
            _ = try JSONDecoder().decode(Integration.self, from: json)
        }
    }

    @Test
    func ephemeralMCPWithNilAllowedTools() throws {
        let integration = Integration.ephemeralMCP(serverLabel: "srv", serverURL: "http://localhost:9000", allowedTools: nil)
        let json = String(data: try JSONEncoder().encode(integration), encoding: .utf8)!
        #expect(json.contains("\"type\":\"ephemeral_mcp\""))
        #expect(!json.contains("allowed_tools"))
    }

    @Test
    func pluginRoundTrip() throws {
        let original = Integration.plugin(id: "my-plugin", allowedTools: ["read", "write"])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Integration.self, from: data)
        if case .plugin(let id, let tools) = decoded {
            #expect(id == "my-plugin")
            #expect(tools == ["read", "write"])
        } else {
            Issue.record("Expected plugin after round-trip")
        }
    }

    @Test
    func ephemeralMCPRoundTrip() throws {
        let original = Integration.ephemeralMCP(serverLabel: "srv", serverURL: "http://localhost:8080", allowedTools: ["search"])
        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(Integration.self, from: data)
        if case .ephemeralMCP(let label, let url, let tools) = decoded {
            #expect(label == "srv")
            #expect(url == "http://localhost:8080")
            #expect(tools == ["search"])
        } else {
            Issue.record("Expected ephemeral MCP after round-trip")
        }
    }
}
