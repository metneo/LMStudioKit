import Testing
@testable import LMStudioKit
import Foundation

// MARK: - LMStudioConfig Tests

struct LMStudioConfigTests {
    @Test
    func defaultInitialization() {
        let config = LMStudioConfig()
        #expect(config.baseURL == URL(string: "http://localhost:1234"))
        #expect(config.apiToken == nil)
    }

    @Test
    func customBaseURL() {
        let url = URL(string: "http://192.168.1.100:8080")!
        let config = LMStudioConfig(baseURL: url)
        #expect(config.baseURL == url)
        #expect(config.apiToken == nil)
    }

    @Test
    func withAPIToken() {
        let token = "test-token-123"
        let config = LMStudioConfig(baseURL: URL(string: "http://localhost:1234")!, apiToken: token)
        #expect(config.baseURL == URL(string: "http://localhost:1234"))
        #expect(config.apiToken == token)
    }

    @Test
    func withEmptyAPIToken() {
        let config = LMStudioConfig(baseURL: URL(string: "http://localhost:1234")!, apiToken: "")
        #expect(config.apiToken == "")
    }

    @Test
    func defaultBaseURLIsLocalhost1234() {
        let config = LMStudioConfig()
        #expect(config.baseURL.host == "localhost")
        #expect(config.baseURL.port == 1234)
    }
}
