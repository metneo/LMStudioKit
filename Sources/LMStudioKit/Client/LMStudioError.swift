import Foundation

// MARK: - Error Types

/// Errors that can occur when interacting with the LM Studio API.
public enum LMStudioError: Error, LocalizedError {
    /// The server returned an invalid or unexpected response.
    case invalidResponse

    /// An HTTP error occurred with the given status code.
    case httpError(statusCode: Int, data: Data)

    /// An error occurred during streaming response processing.
    case streamingError(String)

    /// A localized description of the error.
    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let statusCode, _):
            return "HTTP error: \(statusCode)"
        case .streamingError(let message):
            return "Streaming error: \(message)"
        }
    }
}
