import Testing
@testable import LMStudioKit
import Foundation

// MARK: - LMStudioError Tests

struct LMStudioErrorTests {
    @Test
    func invalidResponseDescription() {
        let error = LMStudioError.invalidResponse
        #expect(error.errorDescription == "Invalid response from server")
    }

    @Test
    func httpErrorDescription() {
        let error = LMStudioError.httpError(statusCode: 404, data: Data())
        #expect(error.errorDescription == "HTTP error: 404")
    }

    @Test
    func streamingErrorDescription() {
        let error = LMStudioError.streamingError("Connection lost")
        #expect(error.errorDescription == "Streaming error: Connection lost")
    }

    @Test
    func httpErrorWithVariousStatusCodes() {
        #expect(LMStudioError.httpError(statusCode: 404, data: Data()).errorDescription == "HTTP error: 404")
        #expect(LMStudioError.httpError(statusCode: 500, data: Data()).errorDescription == "HTTP error: 500")
    }
}
