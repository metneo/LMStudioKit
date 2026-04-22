import Foundation

/// Configuration settings for connecting to an LM Studio server.
///
/// Use this struct to specify the server URL and optional API token for authentication.
public struct LMStudioConfig: Sendable {
    /// The base URL of the LM Studio server.
    ///
    /// Defaults to `http://localhost:1234`.
    public let baseURL: URL

    /// Optional API token for authentication.
    ///
    /// If provided, the token will be sent as a Bearer token in the Authorization header.
    public let apiToken: String?

    /// Creates a new configuration for connecting to LM Studio.
    ///
    /// - Parameters:
    ///   - baseURL: The base URL of the LM Studio server. Defaults to localhost:1234.
    ///   - apiToken: Optional API token for authentication.
    public init(baseURL: URL = URL(string: "http://localhost:1234")!, apiToken: String? = nil) {
        self.baseURL = baseURL
        self.apiToken = apiToken
    }
}
