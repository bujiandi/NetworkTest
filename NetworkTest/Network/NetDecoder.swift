//
//  NetDecoder.swift
//  NetworkTest
//
//  Created by 慧趣小歪 on 2018/4/20.
//  Copyright © 2018年 慧趣小歪. All rights reserved.
//

import Foundation


public protocol NetDecoder {
    
    associatedtype Result
    
    func decode(data:Data) throws -> Result
    
}


open class NetHTMLDecoder : NetDecoder {
   
    public typealias Result = String
    
    open func decode(data:Data) throws -> String {
        guard let result = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "未知的数据格式或内容编码", code: -10001, userInfo: ["data":data])
        }
        return result
    }
}


open class NetJSONDecoder : NetDecoder {
    
    public typealias Result = JSON

    open func decode(data:Data) throws -> JSON {
        
        var result:JSON = .null
        do {
            result = try JSONDecoder().decode(JSON.self, from: data)
        } catch (let error) {
            throw NSError(domain: "未知的数据格式或内容编码", code: -10001, userInfo: ["data":data, "jsonError":error])
        }
        return result
    }
}

open class NetDownDecoder : NetDecoder {
    
    public typealias Result = Data
    
    open func decode(data:Data) throws -> Data {
        return data
    }

}
