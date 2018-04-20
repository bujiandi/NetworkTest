//
//  NetEncoder.swift
//  NetworkTest
//
//  Created by 慧趣小歪 on 2018/4/20.
//  Copyright © 2018年 慧趣小歪. All rights reserved.
//

import Foundation

public protocol NetEncoder {
    
    var data:Data { get }
    
}

// MARK: - NetParamsEncoder post参数请求
open class NetParamsEncoder : NetEncoder {
    
    var _data:Data = Data()
    
    public var data: Data { return _data }
    
}

// MARK: - NetParamsEncoder post参数请求
open class NetJSONEncoder : NetEncoder {
    
    var _data:Data = Data()
    
    public var data: Data { return _data }
    
}


// MARK: - NetParamsEncoder post参数请求
open class NetUploadEncoder : NetEncoder {
    
    var _data:Data = Data()
    
    public var data: Data { return _data }
    
}


