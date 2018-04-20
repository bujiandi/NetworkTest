//
//  JSON.swift
//  SuperWriting
//
//  Created by 慧趣小歪 on 16/9/24.
//  Copyright © 2016年 yFenFen. All rights reserved.
//

import Foundation

public protocol JSONDictionary {
    subscript(key:String) -> JSON { get set }
}

public enum JSON:JSONDictionary {
    
    case object (Object)
    case array  ([JSON])
    case string (String)
    case number (NSNumber)
    case bool   (Bool)
    case null
    case error  (String)
    
    public subscript(key:String) -> JSON {
        get {
            switch self {
            case .error:
                return self
            case .object(let obj):
                return obj[key] as? JSON ?? JSON.null
            case .array(let list):
                if let index = Int(key) {
                    return index >= list.count ?
                        JSON.error("error: index out of bounds in array:\n\(self)") :
                        list[index]
                }
                fallthrough
            default:
                return JSON.error("error: key[\(key)] not exists and self not json object:\n\(self)")
            }
        }
        set {
            switch self {
            case .object(let obj):
                obj[key] = newValue
            case .array(var list):
                if let index = Int(key), index <= list.count {
                    list[index] = newValue
                    self = .array(list)
                    return
                }
                fallthrough
            default:
                fatalError("error: can't set value(\(newValue) to key:(\(key)) in object:\n\(self))")
            }
        }
    }
    
    
    public subscript(position:Int) -> JSON {
        get {
            switch self {
            case .error:
                return self
            case .object(let obj):
                if position < obj.count {
                    return obj[ObjectIndex(rawValue: position)].1;
                }
                return JSON.error("error: index out of bounds in object:\n\(self)")
            case .array(let array):
                if position < array.count {
                    return array[position]
                }
                return JSON.error("error: index out of bounds in array:\n\(self)")
            default:
                return JSON.error("error: index out of bounds in other:\n\(self)")
            }
        }
        set {
            switch self {
            case .object(let obj):
                if position >= obj.count {
                    fatalError("error: set index out of bounds in object:\n\(self))")
                }
                obj[ObjectIndex(rawValue: position)] = (obj._keys[position], newValue)
            case .array(var list):
                if position > list.count {
                    fatalError("error: set index out of bounds in array:\n\(self))")
                }
                list[position] = newValue
                self = .array(list)
            default:
                fatalError("error: set index out of bounds in other:\n\(self))")
            }
        }
    }

    public mutating func append(_ item:JSON) {
        
        if case .array(var list) = self {
            list.append(item)
            self = .array(list)
        } else if case .null = self {
            
        } else {
            fatalError("error: can't append in other:\n\(self)) by item\(item)")
        }
    }
    
    @discardableResult
    public mutating func remove(forKey key:String) -> JSON {
        var result = JSON.null
        if case .object(let obj) = self {
            result = obj.remove(forKey: key)
            self = .object(obj)
        } else {
            print("error: can't remove in other:\n\(self)) by key\(key)")
        }
        return result
    }
    
    public mutating func update(_ item:JSON) {
        self = item
    }
    
    public func contains(_ key:String) -> Bool {
        if case .object(let obj) = self {
            return obj._keys.contains(key)
        }
        return false
    }
}

extension JSON {
    
    public init(_ any:Any?) {
        self = JSON.from(any)
    }
    
    internal static func from(_ any:Any?) -> JSON {
        switch any {
        case (let v as JSON):
            return v
        case (let v as Object):
            return .object(v)
        case (let v as NSDictionary):
            return .object(JSON.Object(v))
        case (let v as NSArray):
            return .array(v.map({ return JSON.from($0) }))
        case (let v as String):
            return .string(v)
        case (let v as Double):
            return .number(NSNumber(value: v))
        case (let v as Float):
            return .number(NSNumber(value: v))
        case (let v as Int64):
            return .number(NSNumber(value: v))
        case (let v as UInt64):
            return .number(NSNumber(value: v))
        case (let v as Int):
            return .number(NSNumber(value: v))
        case (let v as UInt):
            return .number(NSNumber(value: v))
        case (let v as Int32):
            return .number(NSNumber(value: v))
        case (let v as UInt32):
            return .number(NSNumber(value: v))
        case (let v as Int16):
            return .number(NSNumber(value: v))
        case (let v as UInt16):
            return .number(NSNumber(value: v))
        case (let v as Int8):
            return .number(NSNumber(value: v))
        case (let v as UInt8):
            return .number(NSNumber(value: v))
        case (let v as Bool):
            return .bool(v)
        case (_ as NSNull):
            return .null
        default:
            let mirror = Mirror(reflecting: any as Any)
            if  mirror.displayStyle == .optional,
                mirror.children.count == 0 {
                return .null
            }
        }
        return .error("unknow json value:\(String(describing: any))")
    }
    
}


extension JSON : Sequence {
    
}

extension JSON : Collection {    
    
    public typealias Index = Int
    
    public var startIndex: Index {
        return 0
    }

    public var endIndex: Index {
        switch self {
        case let .array(list): return list.count
        case let .object(obj): return obj.count
        default:break
        }
        return 0
    }

    
    public typealias SubSequence = ArraySlice<JSON>
    
    public subscript(bounds: Range<Index>) -> ArraySlice<JSON> {
        get {
            switch self {
            case let .array(list): return list[bounds]
            //case let .object(obj as JSON.Object): return obj[bounds]
            default: break
            }
            return []
        }
        set {
            switch self {
            case var .array(list):
                list[bounds] = newValue
                self = .array(list)
            //case let .object(obj as JSON.Object): return obj[bounds]
            default: break
            }
        }
    }
    
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Index) -> Index {
        return i + 1
    }
    
    /// Replaces the given index with its successor.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    public func formIndex(after i: inout Index) {
//        if i >= endIndex {
//            fatalError("index out of range:\(startIndex..<endIndex)")
//        }
        i += 1
    }
}

extension JSON : MutableCollection {

    
}

extension Encodable {
    public func serialize() throws -> Data {
        return try JSONEncoder().encode(self)
    }
}

extension String : CodingKey {
    public init(stringValue: String) {
        self = stringValue
    }
    public var stringValue: String {
        return self
    }
    
    public init?(intValue: Int) {
        self = "Index \(intValue)"
    }
    public var intValue: Int? {
        if self.hasPrefix("Index ") {
            return Int(suffix(from: index(startIndex, offsetBy: 6)))
        }
        return nil
    }
}
