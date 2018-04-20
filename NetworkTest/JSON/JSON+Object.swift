//
//  JSON+Object.swift
//  Tools
//
//  Created by 慧趣小歪 on 17/4/28.
//
//

import Foundation

fileprivate let commaSeparator:String = ","
fileprivate let prettySeparator:String = ",\n"

extension Data {
    fileprivate mutating func append(dataBy string: String, using chartSet:String.Encoding = .utf8) {
        guard let data = string.data(using: chartSet) else {
            #if DEBUG
                fatalError("error: can't append \"\(string)\" in data using \(chartSet)")
            #else
                return print("error: can't append \"\(string)\" in data using \(chartSet)")
            #endif
        }
        self.append(data)
    }
}

extension JSON {
    
    public struct ObjectIndex: RawRepresentable {
        public typealias RawValue = Int
        public var rawValue:RawValue
        public init(rawValue: RawValue) { self.rawValue = rawValue }
    }
    
    public final class Object {
        public typealias Key = String
        public typealias Value = Any?
        
        internal var _map:[String: JSON]
        internal var _keys:[String]
        
        public required init() {
            _map = [:]
            _keys = []
        }
        
        public required init(dictionaryLiteral elements: (Key, Value)...) {
            var keys:[String] = []
            var map:[String: JSON] = [:]
            for (key, value) in elements {
                keys.append(key)
                map[key] = JSON.from(value)
            }
            _map = map
            _keys = keys
        }
        
        public func append(value: JSON, for key:String) {
            if let index = _keys.index(of: key) {
                _keys.remove(at: index)
            }
            _map[key] = value
            _keys.append(key)
        }
        
        @discardableResult
        public func remove(forKey key:String) -> JSON {
            if let index = _keys.index(of: key) {
                _keys.remove(at: index)
            }
            return _map.removeValue(forKey: key) ?? JSON.null
        }
    }

}

extension JSON.ObjectIndex : Comparable {
    public static func < (lhs: JSON.ObjectIndex, rhs: JSON.ObjectIndex) -> Bool { return lhs.rawValue <  rhs.rawValue }
    public static func <=(lhs: JSON.ObjectIndex, rhs: JSON.ObjectIndex) -> Bool { return lhs.rawValue <= rhs.rawValue }
    public static func >=(lhs: JSON.ObjectIndex, rhs: JSON.ObjectIndex) -> Bool { return lhs.rawValue >= rhs.rawValue }
    public static func > (lhs: JSON.ObjectIndex, rhs: JSON.ObjectIndex) -> Bool { return lhs.rawValue >  rhs.rawValue }
}

extension JSON.Object : MutableCollection, Sequence {
    
    public typealias _Element = (Key, JSON)
    public typealias Index = JSON.ObjectIndex
    public typealias SubSequence = JSON.Object
    public typealias Iterator =  AnyIterator<(Key, JSON)>
    public typealias IndexDistance = Int
    
    public subscript(position: Index) -> (Key, JSON) {
        get {
            let key = _keys[position.rawValue]
            return (key, _map[key]!)
        }
        set {
            let oldKey = _keys[position.rawValue]
            _map[oldKey] = nil
            let newKey = newValue.0
            _keys[position.rawValue] = newKey
            _map[newKey] = JSON.from(newValue.1)
        }
    }
    
    public var startIndex:Index { return Index(rawValue: 0) }
    public var endIndex:Index { return Index(rawValue: Swift.max(_keys.count - 1, 0)) }
    
    public subscript(key: Key) -> Value {
        get { return _map[key] }
        set { append(value: newValue as? JSON ?? JSON.from(newValue), for: key) }
    }
    
    public func makeIterator() -> AnyIterator<(Key, JSON)> {
        var i:Int = 0
        return AnyIterator { [unowned self] in
            if i >= self._keys.count { return nil }
            let key = self._keys[i]
            defer { i += 1 }
            return (key, self._map[key]!)
        }
    }
    
    public subscript(bounds: Range<Index>) -> SubSequence {
        get {
            let subObject = JSON.Object()
            subObject._keys.reserveCapacity(bounds.upperBound.rawValue - bounds.lowerBound.rawValue)
            for key in _keys[bounds.lowerBound.rawValue..<bounds.upperBound.rawValue] {
                subObject._keys.append(key)
                subObject._map[key] = _map[key]
            }
            return subObject
        }
        set {
            let range:Range<Int> = bounds.lowerBound.rawValue..<bounds.upperBound.rawValue
            for key in _keys[range] {
                _map[key] = nil
            }
            _keys.replaceSubrange(range, with: newValue._keys)
            for (key, value) in newValue {
                _map[key] = value
            }
        }
    }
    
    public func index(after i: Index) -> Index {
        return Index(rawValue: i.rawValue + 1)
    }
    
}

extension JSON.Object : ExpressibleByDictionaryLiteral {
    
    public convenience init(_ dictionary:NSDictionary) {
        self.init()
        _keys.reserveCapacity(dictionary.count)
        for (keyAny, value) in dictionary {
            let key = "\(keyAny)"
            _keys.append(key)
            _map[key] = JSON.from(value)
        }
    }
    
}

extension JSON.Object : Decodable {
    public convenience init(from decoder: Decoder) throws {
        self.init()
        let container = try decoder.container(keyedBy: String.self)
        _keys = container.allKeys
        _map.reserveCapacity(_keys.count)
        for key in _keys {
            _map[key] = try container.decode(JSON.self, forKey: key)
        }
    }
}

extension JSON.Object : Encodable {
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: String.self)
        for key in _keys {
            try container.encode(_map[key]!, forKey: key)
        }
    }
}

// MARK: - JSON description
extension JSON.Object : CustomStringConvertible {
    
    public var description: String {
        var data = Data()
        tersePrinting(data: &data)
        return String(data: data, encoding: .utf8) ?? "{}"
    }
    
    public func tersePrinting(data: inout Data) {
        var isEmpty:Bool = true
        data.append(dataBy:"{")
        for key in _keys {
            guard let value = _map[key] else { continue }
            if !isEmpty {
                data.append(dataBy:commaSeparator)
            }
            isEmpty = false
            data.append(dataBy:"\"")
            data.append(dataBy:key)
            data.append(dataBy:"\":")
            value.tersePrinting(data: &data)
        }
        data.append(dataBy:"}")
    }
}

extension JSON.Object : CustomDebugStringConvertible {
    
    public var debugDescription: String {
        var data = Data()
        data.append(dataBy:"\n")
        prettyPrinting(retract: 0, data: &data)
        return String(data: data, encoding: .utf8) ?? "{}"
    }
    
    public func prettyPrinting(retract:Int, data: inout Data) {
        var isEmpty:Bool = true
        let oneRetract = String(repeating: " ", count: 4)
        let retractText = String(repeating: oneRetract, count: retract)
        data.append(dataBy:"{\n")
        for key in _keys {
            guard let value = _map[key] else { continue }
            if !isEmpty {
                data.append(dataBy:prettySeparator)
            }
            isEmpty = false
            data.append(dataBy:retractText)
            data.append(dataBy:oneRetract)
            data.append(dataBy:"\"")
            data.append(dataBy:key)
            data.append(dataBy:"\": ")
            value.prettyPrinting(retract: retract + 1, data: &data)
        }
        data.append(dataBy:"\n")
        data.append(dataBy:retractText)
        data.append(dataBy:"}")
        
    }
    
}


extension JSON : CustomStringConvertible {
    
    public var description: String {
        var data = Data()
        tersePrinting(data: &data)
        return String(data: data, encoding: .utf8)!
    }
    
}

extension Array where Element == JSON {
    
    public func tersePrinting(data: inout Data) {
        var isEmpty:Bool = true
        data.append(dataBy:"[")
        for value in self {
            if !isEmpty {
                data.append(dataBy:commaSeparator)
            }
            isEmpty = false
            value.tersePrinting(data: &data)
        }
        data.append(dataBy:"]")
    }
    
    public func prettyPrinting(retract:Int, data: inout Data) {
        var isEmpty:Bool = true
        let oneRetract = String(repeating: " ", count: 4)
        let retractText = String(repeating: oneRetract, count: retract)
        data.append(dataBy:"[\n")
        for value in self {
            if !isEmpty {
                data.append(dataBy:prettySeparator)
            }
            isEmpty = false
            data.append(dataBy:retractText)
            data.append(dataBy:oneRetract)
            value.prettyPrinting(retract: retract + 1, data: &data)
        }
        data.append(dataBy:"\n")
        data.append(dataBy:retractText)
        data.append(dataBy:"]")
    }
}

extension JSON : CustomDebugStringConvertible {
    
    public func tersePrinting(data: inout Data) {
        switch self {
        case let .object(obj):  obj.tersePrinting(data: &data)
        case let .array(array): array.tersePrinting(data: &data)
        case let .number(num):  data.append(dataBy:num.stringValue)
        case let .string(str):  data.append(dataBy:"\"\(str)\"")
        case let .bool(yesno):  data.append(dataBy:yesno ? "true" : "false")
        case let .error(err):   data.append(dataBy:"\"(--->\(err)<---)\"")
        case .null:             data.append(dataBy:"null")
        }
    }
    
    public func prettyPrinting(retract:Int, data: inout Data) {
        switch self {
        case let .object(obj):  obj.prettyPrinting(retract: retract, data: &data)
        case let .array(array): array.prettyPrinting(retract: retract, data: &data)
        case let .number(num):  data.append(dataBy:num.stringValue)
        case let .string(str):  data.append(dataBy:"\"\(str)\"")
        case let .bool(yesno):  data.append(dataBy:yesno ? "true" : "false")
        case let .error(err):   data.append(dataBy:"\"(--->\(err)<---)\"")
        case .null:             data.append(dataBy:"null")
        }
    }
    
    public var debugDescription: String {
        var data = Data()
        data.append(dataBy:"\n")
        prettyPrinting(retract: 0, data: &data)
        return String(data: data, encoding: .utf8) ?? "{}"
    }
}
