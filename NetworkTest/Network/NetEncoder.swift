//
//  NetEncoder.swift
//  NetworkTest
//
//  Created by 慧趣小歪 on 2018/4/25.
//  Copyright © 2018年 慧趣小歪. All rights reserved.
//

import Foundation


public protocol NetEncoder {
    func encode(request:NetRequest, params: inout [(String, Any)])
}

extension NetEncoder {
    
    func value(_ params:[(String,Any)]) -> [String] {
        return params.compactMap {
            
            let key = $0.0
            
            if key.isEmpty { return nil }
            
            let val = unwrapOptionalToString($0.1)
            let k = key.encodeURL()
            let v = val.encodeURL()
            return "\(k)=\(v)"
        }
    }
    
    func url(forRequest request: NetRequest,
             withGetParams gets: [(String, () -> Any)]) -> URL {
        
        var params = gets.map { ($0.0, $0.1() ) }
        encode(request: request, params: &params)
        let text:String = value(params).joined(separator: "&")
        return URL(string: "\(request.url)?\(text)")!
    }
    
}

open class NetParamsEncoder: NetEncoder {
    
    open func encode(request: NetRequest, params: inout [(String, Any)]) {
        
    }
}

//open class NetParamsEncoder {
//
//    func
//
//}
