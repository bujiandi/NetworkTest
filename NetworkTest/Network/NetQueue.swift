//
//  NetQueue.swift
//  NetworkTest
//
//  Created by 慧趣小歪 on 2018/4/19.
//  Copyright © 2018年 慧趣小歪. All rights reserved.
//

import Foundation

open class NetQueue {
    
    /// 创建 HTTP 请求组
    open func http(_ createGroup: (NetGroup) -> Void) -> NetGroup {
        let group = NetGroup(queue: self)
        createGroup(group)
        return group
    }
    
    var ongoingGroup:NetGroup? = nil
    var groups:[NetGroup] = []
    
    /// 队列中 请求组数量
    public var count:Int {
        return groups.count + (ongoingGroup == nil ? 0 : 1)
    }
    
    /// 队列中 所有组 总请求数量
    public var requestCount:Int {
        return groups.reduce(ongoingGroup?.count ?? 0) { $0 + $1.count }
    }
    
    
}
