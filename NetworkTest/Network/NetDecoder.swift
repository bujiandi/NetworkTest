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
    associatedtype Request:NetSuccessable
    
    func decode(request:Request, response:HTTPURLResponse, data:Data) throws -> Result
    
}


open class NetHTMLDecoder : NetDecoder {
   
    public typealias Result = String
    public typealias Request = NetDataRequest
    
    open func decode(request:Request, response:HTTPURLResponse, data:Data) throws -> Result {
        guard let result = String(data: data, encoding: .utf8) else {
            let text = "未知的数据格式或内容编码"
            let info = ["data":data] as [String : Any]
            throw NSError(domain: text, code: -10001, userInfo: info)
        }
        return result
    }
}

open class NetJSONDecoder : NetDecoder {
    
    public typealias Result = JSON
    public typealias Request = NetDataRequest


    open func decode(request:Request, response:HTTPURLResponse, data:Data) throws -> Result {
        
        var result:JSON = .null
        do {
            result = try JSONDecoder().decode(JSON.self, from: data)
        } catch (let error) {
            let text = "未知的数据格式或内容编码"
            let info = ["data":data, "jsonError":error] as [String : Any]
            throw NSError(domain: text, code: -10001, userInfo: info)
        }
        return result
    }
}

open class NetDownDecoder : NetDecoder {
    
    public typealias Result = (URL, Data)
    public typealias Request = NetDownloadRequest
    
    open func decode(request:Request, response:HTTPURLResponse, data:Data) throws -> Result {
        return (request.localURL, data)
    }

}
