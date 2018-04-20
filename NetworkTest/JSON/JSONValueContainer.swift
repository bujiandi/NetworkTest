//
//  JSONValueContainer.swift
//  Tools
//
//  Created by 慧趣小歪 on 2017/11/2.
//

import Foundation

extension JSONDecoding {
    struct ValueContainer : SingleValueDecodingContainer {
        
        let json:JSON
        /// The path of coding keys taken to get to this point in encoding.
        public let codingPath:[CodingKey]
        
        init(_ value:JSON, key:CodingKey? = nil, path:[CodingKey] = []) {
            var list:[CodingKey] = path
            if let last = key {
                list.append(last)
            }
            codingPath = list
            json = value
        }
        // MARK: - SingleValueDecodingContainer
        
        /// Decodes a null value.
        ///
        /// - returns: Whether the encountered value was null.
        public func decodeNil() -> Bool {
            return json.isNull
        }
        
        
        func decode<Number>(_ type: Number.Type) throws -> NSNumber {
            switch json {
            case .number(let num): return num
            case .bool(let yesno): return yesno ? 1 : 0
            case .string(let txt):
                if let value = Double(txt) {
                    return NSNumber(value: value)
                }
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "value not number")
                throw DecodingError.typeMismatch(type, context)
            case .null:
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "value is null")
                throw DecodingError.valueNotFound(type, context)
            default:
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "value not number")
                throw DecodingError.typeMismatch(type, context)
            }
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Bool.Type) throws -> Bool {
            switch json {
            case .number(let num): return num.intValue != 0
            case .bool(let yesno): return yesno
            case .string(let txt):
                if txt == "true" {
                    return true
                } else if txt == "false" {
                    return false
                } else if txt.isNumeric {
                    return Int(txt)! != 0
                }
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "value not boolean")
                throw DecodingError.typeMismatch(type, context)
            case .null:
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "value is null")
                throw DecodingError.valueNotFound(type, context)
            default:
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "value not boolean")
                throw DecodingError.typeMismatch(type, context)
            }
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Int.Type) throws -> Int {
            return try decode(NSNumber.self).intValue
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Int8.Type) throws -> Int8 {
            return try decode(NSNumber.self).int8Value
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Int16.Type) throws -> Int16 {
            return try decode(NSNumber.self).int16Value
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Int32.Type) throws -> Int32 {
            return try decode(NSNumber.self).int32Value
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Int64.Type) throws -> Int64 {
            return try decode(NSNumber.self).int64Value
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: UInt.Type) throws -> UInt {
            return try decode(NSNumber.self).uintValue
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: UInt8.Type) throws -> UInt8 {
            return try decode(NSNumber.self).uint8Value
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: UInt16.Type) throws -> UInt16 {
            return try decode(NSNumber.self).uint16Value
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: UInt32.Type) throws -> UInt32 {
            return try decode(NSNumber.self).uint32Value
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: UInt64.Type) throws -> UInt64 {
            return try decode(NSNumber.self).uint64Value
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Float.Type) throws -> Float {
            return try decode(NSNumber.self).floatValue
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: Double.Type) throws -> Double {
            return try decode(NSNumber.self).doubleValue
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode(_ type: String.Type) throws -> String {
            switch json {
            case .number(let num): return num.description
            case .bool(let yesno): return yesno ? "true" : "false"
            case .string(let txt): return txt
            case .null:
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "value is null")
                throw DecodingError.valueNotFound(type, context)
            default:
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "value not string")
                throw DecodingError.typeMismatch(type, context)
            }
        }
        
        /// Decodes a single value of the given type.
        ///
        /// - parameter type: The type to decode as.
        /// - returns: A value of the requested type.
        /// - throws: `DecodingError.typeMismatch` if the encountered encoded value cannot be converted to the requested type.
        /// - throws: `DecodingError.valueNotFound` if the encountered encoded value is null.
        public func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
            switch json {
            case .null:
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: "value is null")
                throw DecodingError.valueNotFound(type, context)
            case .error(let text):
                let context = DecodingError.Context(codingPath: codingPath, debugDescription: text)
                throw DecodingError.typeMismatch(type, context)
            default:  break
            }
            let decoder = try JSONDecoding(json, path: codingPath)
            return try T(from: decoder)
        }
        
    }
}
