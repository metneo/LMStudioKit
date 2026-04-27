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

    // MARK: - Encoding Tests

    @Test
    func encodingString() throws {
        let json = #""hello""#.data(using: .utf8)!
        let any = try JSONDecoder().decode(AnyCodable.self, from: json)
        let encoder = JSONEncoder()
        let data = try encoder.encode(any)
        let result = String(data: data, encoding: .utf8)!

        #expect(result == #""hello""#)
    }

    @Test
    func encodingInt() throws {
        let json = "42".data(using: .utf8)!
        let any = try JSONDecoder().decode(AnyCodable.self, from: json)
        let encoder = JSONEncoder()
        let data = try encoder.encode(any)
        let result = String(data: data, encoding: .utf8)!

        #expect(result == "42")
    }

    @Test
    func encodingDouble() throws {
        let json = "3.14".data(using: .utf8)!
        let any = try JSONDecoder().decode(AnyCodable.self, from: json)
        let encoder = JSONEncoder()
        let data = try encoder.encode(any)
        let result = String(data: data, encoding: .utf8)!

        #expect(result == "3.14")
    }

    @Test
    func encodingBoolTrue() throws {
        let json = "true".data(using: .utf8)!
        let any = try JSONDecoder().decode(AnyCodable.self, from: json)
        let encoder = JSONEncoder()
        let data = try encoder.encode(any)
        let result = String(data: data, encoding: .utf8)!

        #expect(result == "true")
    }

    @Test
    func encodingBoolFalse() throws {
        let json = "false".data(using: .utf8)!
        let any = try JSONDecoder().decode(AnyCodable.self, from: json)
        let encoder = JSONEncoder()
        let data = try encoder.encode(any)
        let result = String(data: data, encoding: .utf8)!

        #expect(result == "false")
    }

    @Test
    func encodingArrayThrows() throws {
        let json = "[1, 2, 3]".data(using: .utf8)!
        let any = try JSONDecoder().decode(AnyCodable.self, from: json)
        let encoder = JSONEncoder()

        // Arrays are not encodable by AnyCodable - it throws
        do {
            _ = try encoder.encode(any)
            Issue.record("Should have thrown")
        } catch {
            // Expected - encoding [Any] is not supported
        }
    }

    @Test
    func encodingDictionaryThrows() throws {
        let json = #"{"key": "value"}"#.data(using: .utf8)!
        let any = try JSONDecoder().decode(AnyCodable.self, from: json)
        let encoder = JSONEncoder()

        // Dictionaries are not encodable by AnyCodable - it throws
        do {
            _ = try encoder.encode(any)
            Issue.record("Should have thrown")
        } catch {
            // Expected - encoding [String: Any] is not supported
        }
    }

    @Test
    func decodingAndEncodingRoundTrip() throws {
        let json = #"{"name": "test", "count": 42, "active": true}"#.data(using: .utf8)!
        let any = try JSONDecoder().decode(AnyCodable.self, from: json)

        // Extract and verify values
        let dict = any.value as? [String: Any]
        #expect(dict?["name"] as? String == "test")
        #expect(dict?["count"] as? Int == 42)
        #expect(dict?["active"] as? Bool == true)
    }

    @Test
    func nestedStructureDecoding() throws {
        let json = #"{"user": {"name": "Alice", "age": 30, "active": true, "scores": [10, 20, 30]}}"#.data(using: .utf8)!
        let any = try JSONDecoder().decode(AnyCodable.self, from: json)

        let user = (any.value as? [String: Any])?["user"] as? [String: Any]
        #expect(user?["name"] as? String == "Alice")
        #expect(user?["age"] as? Int == 30)
        #expect(user?["active"] as? Bool == true)
        #expect((user?["scores"] as? [Any])?.count == 3)
    }
}
