//
//  Array+Utils.swift
//
//  Created by bujiandi(慧趣小歪) on 14/10/4.
//

import Foundation


public protocol Enumerable {
    func enumerate() -> AnyIterator<Self>
}

extension Enumerable where Self : Hashable {
    
    private func enumerateEnum<T: Hashable>(_: T.Type) -> AnyIterator<T> {
        var i = 0
        return AnyIterator {
            let next = withUnsafePointer(to: &i) { p in
                p.withMemoryRebound(to: T.self, capacity: 1) { $0.pointee }
            }
            defer { i += 1 }
            return next.hashValue == i ? next : nil
        }
    }
    
    public func enumerate() -> AnyIterator<Self> {
        return enumerateEnum(Self.self)
    }
    
}

extension Int {
    public func times(_ function: (Int) -> Void) {
        for i in 0 ..< self { function(i) }
    }
}

extension Collection {
    
    /*
     *  遍历数组中的元素并加入下标索引 例如:
     *  for (i, item) in array.enumerate() {
     *      print(i, item)
     *  }
     */
    
    public func element(at index:Index) -> Iterator.Element? {
        if !(startIndex..<endIndex).contains(index) { return nil }
        return self[index]
    }
    
    public func set<T>(_ includeElement: (Iterator.Element) -> T) -> Set<T> where T:Hashable {
        var set = Set<T>()
        for item:Iterator.Element in self {
            set.insert(includeElement(item))
        }
        return set
    }
    
    public func joined(separator:String, includeElement:(Iterator.Element) -> String = { unwrapOptionalToString($0) }) -> String {
        var result:String = ""
        for item:Iterator.Element in self {
            if !result.isEmpty { result += separator }
            result += includeElement(item)
        }
        return result
    }
    
    // 利用闭包功能 给数组添加 查找首个符合条件元素 的 方法
    public func find(where includeElement: (Iterator.Element) -> Bool) -> Iterator.Element? {
        for item in self where includeElement(item) {
            return item
        }
        return nil
    }
}

extension Array {
    
    @inline(__always)
    public mutating func appendIgnoreNil(_ element:Element?) {
        if let value = element { append(value) }
    }
    
}

extension MutableCollection where Index == Int {
    
    /// 数据随机乱序
    mutating func shuffleInPlace() {
        if count < 2 { return }
        
        for i in 0..<count - 1 {
            let j = Int(arc4random_uniform(UInt32(count - i))) + 1
            guard i != j else { continue }
            swapAt(i, j) // swap(&self[i], &self[j])
        }
    }
    
}

public func unwrapOptionalToString<T>(_ v:T?) -> String {
    var val:String!
    guard let value = v else { return "" }
    
    let mirror = Mirror(reflecting: value)
    if mirror.displayStyle == .optional {
        let children = mirror.children
        if children.count == 0 {
            val = ""
        } else {
            val = "\(children[children.startIndex].value)"
        }
    } else {
        val = "\(value)"
    }
    
    return val
}
