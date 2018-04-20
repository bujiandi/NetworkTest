//
//  JSONDecoding.swift
//  Tools
//
//  Created by 慧趣小歪 on 2017/11/1.
//

import Foundation


struct JSONDecoding :Decoder {
    
    let json:JSON
    
    /// The path of coding keys taken to get to this point in encoding.
    public let codingPath:[CodingKey]
    
    init(_ value:JSON, key:CodingKey? = nil, path:[CodingKey] = []) throws {
        var list:[CodingKey] = path
        if let last = key {
            list.append(last)
        }
        if case .error(let text) = value {
            let context = DecodingError.Context(codingPath: list, debugDescription: text)
            throw DecodingError.dataCorrupted(context)
        }
        codingPath = list
        json = value
    }
    
    /// Any contextual information set by the user for encoding.
    public var userInfo: [CodingUserInfoKey : Any] { return [:] }
    
    /// Returns the data stored in this decoder as represented in a container appropriate for holding values with no keys.
    ///
    /// - returns: An unkeyed container view into this decoder.
    /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not an unkeyed container.
    public func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        return try UnkeyedContainer(json, path: codingPath)
    }
    
    /// Returns the data stored in this decoder as represented in a container appropriate for holding a single primitive value.
    ///
    /// - returns: A single value container view into this decoder.
    /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not a single value container.
    public func singleValueContainer() throws -> SingleValueDecodingContainer {
        return ValueContainer(json, path: codingPath)
    }
    
    /// Returns the data stored in this decoder as represented in a container keyed by the given key type.
    ///
    /// - parameter type: The key type to use for the container.
    /// - returns: A keyed decoding container view into this decoder.
    /// - throws: `DecodingError.typeMismatch` if the encountered stored value is not a keyed container.
    public func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        if case .object(let obj) = json {
            return KeyedDecodingContainer<Key>(KeyedContainer<Key>(obj, path: codingPath))
        }
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "not object")
        throw DecodingError.typeMismatch(type, context)
    }
    
    
}
