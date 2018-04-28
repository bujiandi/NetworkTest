//
//  UserDefaultTool.swift
//  Tools
//
//  Created by Steven on 2017/9/19.
//
//

import Foundation


public func load<T>(_ value:@autoclosure ()->T?, sift: (T)->T?) -> T? {
    if let v = value() {
        return sift(v)
    }
    return nil
}

public func load<T>(_ value:@autoclosure ()->T, sift: (T)->T) -> T {
    return sift(value())
}

public func load<T>(_ value:@autoclosure ()->T, sift: (T)->T?) -> T? {
    return sift(value())
}

public struct DecoderGetter : Decodable {
    
    public let decoder: Decoder
    public init(from decoder: Decoder) {
        self.decoder = decoder
    }
    
}

open class CodeStruct<T:Codable> : NSObject, NSCoding, RawRepresentable {
    
    public typealias RawValue = T
    
    open let rawValue: T
    public required init(rawValue: RawValue) {
        self.rawValue = rawValue
    }

    public func encode(with aCoder: NSCoder) {
        if let data = try? JSONEncoder().encode(rawValue) {
            aCoder.encode(data)
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        guard let data = aDecoder.decodeData() else { return nil }
        guard let value = try? JSONDecoder().decode(T.self, from:data) else { return nil }
        self.rawValue = value
    }
    
}

extension Encodable where Self : Decodable {
    
    public var archive:CodeStruct<Self> { return CodeStruct(rawValue: self) }
    
}


public protocol UserDefaultsSettable {
   var uniqueKey : String{ get }
}

extension UserDefaultsSettable where Self : RawRepresentable,Self.RawValue == String {
    
    //为所有的Key加上枚举名做命名空间，避免重复
    public var uniqueKey : String {
        
        return "\(Self.self).\(rawValue)"
        
    }
    
    public func store(value : Any?) {
        
        UserDefaults.standard.set(value, forKey: uniqueKey)
        UserDefaults.standard.synchronize()
    }
    
    public func storeBool(value : Bool) {
        UserDefaults.standard.set(value, forKey: uniqueKey)
        UserDefaults.standard.synchronize()
    }
    
    public func storeDouble(value : Double) {
        UserDefaults.standard.set(value, forKey: uniqueKey)
        UserDefaults.standard.synchronize()
    }
    
    public func storeInt(value : Int) {
        UserDefaults.standard.set(value, forKey: uniqueKey)
        UserDefaults.standard.synchronize()
    }
    
    public func storeFloat(value : Float) {
        UserDefaults.standard.set(value, forKey: uniqueKey)
        UserDefaults.standard.synchronize()
    }
    
    public func storeURL(value : URL) {
        UserDefaults.standard.set(value, forKey: uniqueKey)
        UserDefaults.standard.synchronize()
    }
    
    //取值
    
    public var storeValue : Any?{
        
        guard let value = UserDefaults.standard.value(forKey: uniqueKey) else {
            
            return nil
        }
        
        return value
    }
    
    public var storeString : String?{
        return UserDefaults.standard.string(forKey: uniqueKey)
    }
    public var storeBool : Bool?{
        
        return UserDefaults.standard.bool(forKey: uniqueKey)
    }
    public var storeDouble : Double?{
//        return UserDefaults.standard.double(forKey: uniqueKey)
        return Double(UserDefaults.standard.string(forKey: uniqueKey) ?? .Empty)
    }
    public var storeFloat: Float?{
        
//        return UserDefaults.standard.float(forKey: uniqueKey)
        return Float(UserDefaults.standard.string(forKey: uniqueKey) ?? .Empty)
    }
    
    public var storeInt: Int?{
        return Int(UserDefaults.standard.string(forKey: uniqueKey) ?? .Empty)//UserDefaults.standard.integer(forKey: uniqueKey)
    }
    
    public var storeURL: URL?{
        
        return UserDefaults.standard.url(forKey: uniqueKey)
    }
    
    
}
