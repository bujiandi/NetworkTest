//
//  NetGroup.swift
//  NetworkTest
//
//  Created by 慧趣小歪 on 2018/4/19.
//  Copyright © 2018年 慧趣小歪. All rights reserved.
//

import Foundation

open class NetGroup {
    
    public func request(_ url:URL) -> NetRequest {
        let request = NetRequest(group: self, url: url)
        return request
    }
    
    var ongoingRequest:NetRequest? = nil
    var requests:[NetRequest] = []
    
    public var count:Int {
        return requests.count + (ongoingRequest == nil ? 0 : 1)
    }
    
    public unowned let queue:NetQueue
    
    public init(queue:NetQueue) {
        self.queue = queue
    }
    
}
