//
//  NetQueue.swift
//  NetworkTest
//
//  Created by 慧趣小歪 on 2018/4/19.
//  Copyright © 2018年 慧趣小歪. All rights reserved.
//

import Foundation

open class NetQueue {
    
    private var _concurrently:Int
    
    public var threadQueue:DispatchQueue = DispatchQueue.global(qos: .utility)
    // 同时进行的任务数量
    public init(concurrentlyCount:Int) {
        _concurrently = concurrentlyCount
    }
    public init() {
        _concurrently = 1
    }
    
    /// 请求正在进行的组
    lazy var ongoingGroups:[(URLSession, NetGroup)] = {
        var list = [(URLSession, NetGroup)]()
        list.reserveCapacity(_concurrently)
        return list
    }()
    
    /// 队列中等待执行的组
    internal var groups:[NetGroup] = []
    
}

// MARK: - 主要
extension NetQueue {
    
    /// 创建 HTTP 请求组
    open func http(_ createGroup: @escaping (NetGroup) -> Void) -> NetGroup {
        let group = NetGroup(queue: self, retry: createGroup)
        group.resume()
        return group
    }
        
    func resume() {
        if Thread.isMainThread {
            _resume()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?._resume()
            }
        }
    }
    
    private func _resume() {
        while groups.count > 0, ongoingGroups.count < _concurrently {
            let group = groups.removeFirst()
            
            let session = sessionFactory(group)
            
            // 跳过数量为空的组
            if group.count == 0 { continue }
            
            // 将有任务的组添加到请求队列
            ongoingGroups.append((session, group))
            group.ongoingRequest = nil
            group.resume(session: session)
        }
    }
    
    func complete(group:NetGroup) {
        if let index = ongoingGroups.index(where: { $0.1 === group }) {
            ongoingGroups.remove(at: index)
            resume()
        }
    }
    
    func sessionFactory(_ group:NetGroup) -> URLSession {
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config, delegate: nil, delegateQueue: nil)
        
        
        return session
    }
}


// MARK: - 数量
extension NetQueue {
    
    /// 能同时进行的网络请求组数量 [>= 1]
    public var concurrentlyCount:Int {
        get { return _concurrently }
        set {
            // 如果设置的数量小于 1 则忽略
            if newValue < 1 { return }
            _concurrently = newValue
            // 移除多余正在进行的组，并取消组请求，重新加入队列顶部
            while ongoingGroups.count > newValue {
                let (_, last) = ongoingGroups.removeLast()
                last.cancel()
                groups.insert(last, at: 0)
            }
            ongoingGroups.reserveCapacity(newValue)
        }
    }
    
    /// 正在执行的组数量
    public var ongoingCount:Int {
        return ongoingGroups.count
    }
    
    /// 队列中 请求组数量
    public var count:Int {
        return groups.count + ongoingGroups.count
    }
    
    /// 队列中 所有组 总请求数量
    public var requestCount:Int {
        let list = groups + ongoingGroups.map { $0.1 }
        return list.reduce(0) { $0 + $1.count }
    }
    
}
