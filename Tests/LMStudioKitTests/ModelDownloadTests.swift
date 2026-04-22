import Testing
@testable import LMStudioKit
import Foundation

// MARK: - ModelDownloadRequest Tests

struct ModelDownloadRequestTests {
    @Test
    func basicInitialization() {
        let request = ModelDownloadRequest(model: "lmstudio-community/llama-3")
        #expect(request.model == "lmstudio-community/llama-3")
        #expect(request.quantization == nil)
    }

    @Test
    func withQuantization() {
        let request = ModelDownloadRequest(model: "lmstudio-community/llama-3", quantization: "Q4_K_M")
        #expect(request.quantization == "Q4_K_M")
    }
}

// MARK: - ModelDownloadResponse Tests

struct ModelDownloadResponseTests {
    @Test
    func decoding() throws {
        let json = #"{"job_id": "job-123", "status": "downloading", "total_size_bytes": 5000000000}"#.data(using: .utf8)!
        let response = try JSONDecoder().decode(ModelDownloadResponse.self, from: json)
        #expect(response.jobId == "job-123")
        #expect(response.status == "downloading")
    }
}

// MARK: - ModelDownloadStatusResponse Tests

struct ModelDownloadStatusResponseTests {
    @Test
    func decoding() throws {
        let json = #"{"job_id": "job-456", "status": "downloading", "downloaded_bytes": 7500000000, "speed_bytes_per_second": 2500000}"#.data(using: .utf8)!
        let response = try JSONDecoder().decode(ModelDownloadStatusResponse.self, from: json)
        #expect(response.downloadedBytes == 7500000000)
        #expect(response.speedBytesPerSecond == 2500000)
    }

    @Test
    func decodingCompleted() throws {
        let json = #"{"job_id": "job-789", "status": "completed", "completed_at": "2024-01-15T10:35:00Z"}"#.data(using: .utf8)!
        let response = try JSONDecoder().decode(ModelDownloadStatusResponse.self, from: json)
        #expect(response.status == "completed")
        #expect(response.completedAt == "2024-01-15T10:35:00Z")
    }
}
