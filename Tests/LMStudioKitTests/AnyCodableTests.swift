import Testing
@testable import LMStudioKit
import Foundation

// MARK: - AnyCodable Tests

struct AnyCodableTests {
    @Test
    func stringValue() throws {
        let json = #""hello""#.data(using: .utf8)!
        let any = try JSONDecoder().decode(AnyCodable.self, from: json)
        #expect(any.value as? String == "hello")
    }

    @Test
    func intValue() throws {
        let json = "42".data(using: .utf8)!
        let any = try JSONDecoder().decode(AnyCodable.self, from: json)
        #expect(any.value as? Int == 42)
    }

    @Test
    func doubleValue() throws {
        let json = "3.14".data(using: .utf8)!
        let any = try JSONDecoder().decode(AnyCodable.self, from: json)
        #expect(any.value as? Double == 3.14)
    }

    @Test
    func boolValue() throws {
        let json = "true".data(using: .utf8)!
        let any = try JSONDecoder().decode(AnyCodable.self, from: json)
        #expect(any.value as? Bool == true)
    }

    @Test
    func arrayValue() throws {
        let json = "[1, 2, 3]".data(using: .utf8)!
        let any = try JSONDecoder().decode(AnyCodable.self, from: json)
        #expect((any.value as? [Any])?.count == 3)
    }

    @Test
    func dictValue() throws {
        let json = #"{"key": "value"}"#.data(using: .utf8)!
        let any = try JSONDecoder().decode(AnyCodable.self, from: json)
        #expect((any.value as? [String: Any])?["key"] as? String == "value")
    }

    @Test
    func nestedObject() throws {
        let json = #"{"outer": {"inner": "value"}}"#.data(using: .utf8)!
        let any = try JSONDecoder().decode(AnyCodable.self, from: json)
        let outer = (any.value as? [String: Any])?["outer"] as? [String: Any]
        #expect(outer?["inner"] as? String == "value")
    }
}
