//
//  JSON+GetValue.swift
//  Tools
//
//  Created by 慧趣小歪 on 17/4/28.
//
//

import Foundation
import CoreGraphics



extension JSON {
    
    public var array:[JSON] {
        if case .array(let list) = self { return list }
        return []
    }
    
    public var isArray:Bool {
        if case .array = self { return true }
        return false
    }
    public var isObject:Bool {
        if case .object = self { return true }
        return false
    }
    public var isNumber:Bool {
        if case .number = self { return true }
        return false
    }
    public var isString:Bool {
        if case .string = self { return true }
        return false
    }
    public var isNull:Bool {
        if case .null = self { return true }
        return false
    }
    public var isError:Bool {
        if case .error = self { return true }
        return false
    }
    
    public var optionalString:String? {
        switch self {
        case let .string(text): return text
        case let .number(aNum): return String(describing: aNum)
        case let .bool(value):  return value ? "true" : "false"
        case let .array(list):  return list.description
        case let .object(obj):  return obj.description
        case let .error(text):
            #if DEBUG
                fatalError(text)
            #else
                return nil
            #endif
        case .null: return nil
        }
    }
    
    public var string:String {
        if case .null = self { return "null" }
        return optionalString ?? ""
    }
    
    public var optionalInt:Int? {
        switch self {
        case let .string(text): return Int(text)
        case let .number(aNum): return aNum.intValue
        case let .bool(value):  return value ? 1 : 0
        case let .array(list):  return list.count
        case let .object(obj):  return obj.count
        case let .error(text):
            #if DEBUG
                fatalError(text)
            #else
                return nil
            #endif
        case .null: return nil
        }
    }
    
    public var int:Int {
        return optionalInt ?? 0
    }
    
    
    public var optionalFloat:Float? {
        switch self {
        case let .string(text): return Float(text)
        case let .number(aNum): return aNum.floatValue
        case let .bool(value):  return value ? 1 : 0
        case let .array(list):  return Float(list.count)
        case let .object(obj):  return Float(obj.count)
        case let .error(text):
            #if DEBUG
                fatalError(text)
            #else
                return nil
            #endif
        case .null: return nil
        }
    }
    
    public var float:Float {
        return optionalFloat ?? 0
    }
    
    public var optionalBool:Bool? {
        switch self {
        case let .string(text):
            return text == "true" ? true : (text == "false" ? false : nil)
        case let .number(aNum): return aNum.doubleValue != 0
        case let .bool(value):  return value
        case let .error(text):
            #if DEBUG
                fatalError(text)
            #else
                return nil
            #endif
        default: return nil
        }
    }
    public var bool:Bool { return optionalBool ?? false }
    
    public var optionalCGFloat:CGFloat? {
        guard let value = optionalDouble else { return nil }
        return CGFloat(value)
    }
    public var cgFloat:CGFloat { return optionalCGFloat ?? 0 }
    
    public var optionalDouble:Double? {
        switch self {
        case let .string(text): return Double(text)
        case let .number(aNum): return aNum.doubleValue
        case let .bool(value):  return value ? 1 : 0
        case let .array(list):  return Double(list.count)
        case let .object(obj):  return Double(obj.count)
        case let .error(text):
            #if DEBUG
                fatalError(text)
            #else
                return nil
            #endif
        case .null: return nil
        }
    }
    public var double:Double { return optionalDouble ?? 0 }
    
    
    public var uint:UInt {
        switch self {
        case let .string(text): return UInt(text) ?? 0
        case let .number(aNum): return aNum.uintValue
        case let .bool(value):  return value ? 1 : 0
        case let .array(list):  return UInt(list.count)
        case let .object(obj):  return UInt(obj.count)
        case let .error(text):
            #if DEBUG
                fatalError(text)
            #else
                return 0
            #endif
        case .null: return 0
        }
    }
    
    public var int64:Int64 {
        switch self {
        case let .string(text): return Int64(text) ?? 0
        case let .number(aNum): return aNum.int64Value
        case let .bool(value):  return value ? 1 : 0
        case let .array(list):  return Int64(list.count)
        case let .object(obj):  return Int64(obj.count)
        case let .error(text):
            #if DEBUG
                fatalError(text)
            #else
                return 0
            #endif
        case .null: return 0
        }
    }
    
    public var int32:Int32 {
        switch self {
        case let .string(text): return Int32(text) ?? 0
        case let .number(aNum): return aNum.int32Value
        case let .bool(value):  return value ? 1 : 0
        case let .array(list):  return Int32(list.count)
        case let .object(obj):  return Int32(obj.count)
        case let .error(text):
            #if DEBUG
                fatalError(text)
            #else
                return 0
            #endif
        case .null: return 0
        }
    }
    
    public var int16:Int16 {
        switch self {
        case let .string(text): return Int16(text) ?? 0
        case let .number(aNum): return aNum.int16Value
        case let .bool(value):  return value ? 1 : 0
        case let .array(list):  return Int16(list.count)
        case let .object(obj):  return Int16(obj.count)
        case let .error(text):
            #if DEBUG
                fatalError(text)
            #else
                return 0
            #endif
        case .null: return 0
        }
    }
    
    public var int8:Int8 {
        switch self {
        case let .string(text): return Int8(text) ?? 0
        case let .number(aNum): return aNum.int8Value
        case let .bool(value):  return value ? 1 : 0
        case let .array(list):  return Int8(list.count)
        case let .object(obj):  return Int8(obj.count)
        case let .error(text):
            #if DEBUG
                fatalError(text)
            #else
                return 0
            #endif
        case .null: return 0
        }
    }

}
