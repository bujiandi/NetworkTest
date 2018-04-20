//
//  NetRequest.swift
//  NetworkTest
//
//  Created by 慧趣小歪 on 2018/4/19.
//  Copyright © 2018年 慧趣小歪. All rights reserved.
//

import Foundation

public protocol NetSuccessable {}


open class NetRequest {
 
    public unowned let group:NetGroup
    public let url:URL
    public var encoder:NetEncoder
    
    public var queue:NetQueue { return group.queue }

    public init(encoder:NetEncoder, group:NetGroup, url:URL) {
//        self.decoder = decoder
        self.encoder = encoder
        self.group = group
        self.url = url
    }
    
    
}

extension NetRequest : NetSuccessable {}

extension NetSuccessable where Self : NetRequest {
    
    func onSuccess(_ callback:(NetResponse<Self>) -> Void) -> Self {
        
        return self
    }
}
