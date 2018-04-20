//
//  JSON+Deserialize.swift
//  Tools
//
//  Created by 慧趣小歪 on 17/4/28.
//
//

import Foundation


public protocol ModelByJSON {
    init(json:JSON) throws
}

extension Array : ModelByJSON {
    public init(json: JSON) throws {
        guard case .array(let list) = json else {
            throw NSError(domain: "json not array", code: -1, userInfo: nil)
        }
        guard let decodable = Element.self as? ModelByJSON.Type else {
            throw NSError(domain: "element not ModelByJSON", code: -1, userInfo: nil)
        }
        self = list.compactMap { (try? decodable.init(json: $0)) as? Element }
    }
}

extension Array where Iterator.Element : ModelByJSON {
    init(json:JSON) throws {
        guard case .array(let list) = json else {
            throw NSError(domain: "json not array", code: -1, userInfo: nil)
        }
        self = list.compactMap { try? Iterator.Element.init(json: $0) }
    }
}

extension Dictionary : ModelByJSON {
    public init(json: JSON) throws {
        guard case .object(let obj) = json else {
            throw NSError(domain: "json not object", code: -1, userInfo: nil)
        }
        guard let hashabled = Key.self as? String.Type else {
            throw NSError(domain: "key not String", code: -1, userInfo: nil)
        }
        guard let decodable = Value.self as? ModelByJSON.Type else {
            throw NSError(domain: "element not ModelByJSON", code: -1, userInfo: nil)
        }
        var dict:[Key:Value] = [:]
        for (k, v) in obj {
            let key = hashabled.init(k) as! Key
            let val = (try? decodable.init(json: v)) as? Value
            dict[key] = val
        }
        self = dict
    }
}

extension Dictionary where Key == String, Value : ModelByJSON {
    public init(json: JSON) throws {
        guard case .object(let obj) = json else {
            throw NSError(domain: "json not object", code: -1, userInfo: nil)
        }
        var dict:[Key:Value] = [:]
        for (k, v) in obj {
            dict[k] = try? Value(json: v)
        }
        self = dict
    }
}





extension JSON {
    /// Decodes a top-level value of the given type from the given JSON representation.
    ///
    /// - parameter type: The type of the value to decode.
    /// - parameter data: The data to decode from.
    /// - returns: A value of the requested type.
    /// - throws: `DecodingError.dataCorrupted` if values requested from the payload are corrupted, or if the given data is not valid JSON.
    /// - throws: An error if any value throws an error during decoding.
    public func decode<T>(_ :T.Type) throws -> T where T : Decodable {
//        var data = Data()
//        tersePrinting(data: &data)
//        return try JSONDecoder().decode(T.self, from: data)
        return try T(from: try JSONDecoding(self))
    }
}

extension String {
    public var deserializeJSON:JSON {
        guard let data = data(using: .utf8) else {
            return JSON.error("\"\(self)\" \nString is not utf8")
        }
        return data.deserializeJSON
    }
}

extension Data {
    public var deserializeJSON:JSON {
        do {
            let decoder = JSONDecoder()
            decoder.nonConformingFloatDecodingStrategy = .convertFromString(positiveInfinity: "∞", negativeInfinity: "-∞", nan: "NaN")
            return try decoder.decode(JSON.self, from: self)
//            let item = try JSONSerialization.jsonObject(with: self, options: [.allowFragments])
//            return JSON.from(item)
        } catch let error {
            return JSON.error(error.localizedDescription)
        }
        
    }
}


extension JSON : Decodable {
    public init(from decoder: Decoder) throws {
        if decoder is JSONDecoding {
            self = (decoder as! JSONDecoding).json
            return
        }
        if let container = try? decoder.container(keyedBy: String.self) {
            let obj = JSON.Object()
            for key in container.allKeys {
                let value = try container.decode(JSON.self, forKey: key)
                obj.append(value: value, for: key)
            }
            self = .object(obj)
            return
        } else if var container = try? decoder.unkeyedContainer() {
            var list:[JSON] = []
            while !container.isAtEnd {
                if let v = try? container.decode(JSON.self) {
                    list.append(v)
                }
            }
            self = .array(list)
            return
        } else if let container = try? decoder.singleValueContainer(), !container.decodeNil() {
            if let v = try? container.decode(Bool.self) {
                self = .bool(v)
            } else if let v = try? container.decode(Double.self) {
                self = .number(NSNumber(value: v))
            } else {
                do {
                    let v = try container.decode(String.self)
                    self = .string(v)
                } catch let error {
                    self = .error(error.localizedDescription)
                }
            }
            return
        }
        self = .null
    }
}

extension JSON : Encodable {
    public func encode(to encoder: Encoder) throws {
        switch self {
        case let .object(obj):
            var container = encoder.container(keyedBy: String.self)
            for (k, v) in obj {
                try container.encode(v, forKey: k)
            }
        case let .array(array):
            var container = encoder.unkeyedContainer()
            try container.encode(contentsOf: array)
        case let .number(num):
            var container = encoder.singleValueContainer()
            try container.encode(num.doubleValue)
        case let .string(str):
            var container = encoder.singleValueContainer()
            try container.encode(str)
        case let .bool(yesno):
            var container = encoder.singleValueContainer()
            try container.encode(yesno)
        case let .error(err):
            var container = encoder.singleValueContainer()
            try container.encode("(--->\(err)<---)")
        case .null:
            var container = encoder.singleValueContainer()
            try container.encodeNil()
        }
    }
}

