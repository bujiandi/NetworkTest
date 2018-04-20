//
//  NetResponse.swift
//  NetworkTest
//
//  Created by 慧趣小歪 on 2018/4/20.
//  Copyright © 2018年 慧趣小歪. All rights reserved.
//

import Foundation

open class NetResponse<Request> where Request : NetRequest {
    
    public unowned let request:Request
    
    public init(request: Request) {
        self.request = request
    }
    
}
