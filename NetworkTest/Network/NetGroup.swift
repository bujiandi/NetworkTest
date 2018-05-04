//
//  NetGroup.swift
//  NetworkTest
//
//  Created by 慧趣小歪 on 2018/4/19.
//  Copyright © 2018年 慧趣小歪. All rights reserved.
//

import Foundation

open class NetGroup {
    
    public var progress:Progress = Progress(totalUnitCount: 0)
    
    public static let ErrorUserInfoKey = "key.net.group.userinfo"
    
    public func request(_ url:URL) -> NetDataRequest {
        let request = NetDataRequest(group: self, url: url)
        return request
    }
    
    var ongoingRequest:(URLSessionTask, NetRequest)? = nil
    var requests:[NetRequest] = []
    
    public func append(_ request:NetRequest) {
        requests.append(request)
        progress.totalUnitCount += 1
    }
    
    public var count:Int {
        return requests.count + (ongoingRequest == nil ? 0 : 1)
    }
    
    public unowned let queue:NetQueue
    let retry:(NetGroup) -> Void
    
    public init(queue:NetQueue, retry: @escaping (NetGroup) -> Void) {
        self.queue = queue
        self.retry = retry
    }
    
    func createRequests() {
        requests.removeAll(keepingCapacity: true)
        progress.totalUnitCount = 0
        progress.completedUnitCount = 0
        retry(self)
    }
    
    public func resume() {
        createRequests()
        if !_isInQueue {
            queue.groups.append(self)
            queue.resume()
        } else {
            queue.restart(group: self)
        }
    }
    
    func resume(session:URLSession) {
        if ongoingRequest != nil { return }
        if requests.count == 0 {
            queue.complete(group: self)
            _complete(with: nil)
            return
        }
        let request = requests.removeFirst()
        let task = request.resumeTask(session: session) {
            [weak self] (data, response, error, cancelContinue) in
            
            if (error as NSError?)?.code == -999, !cancelContinue { return }
            
            guard let this = self else { return }
            this.ongoingRequest = nil
            // 如果 解析 响应结果 成功 则继续进行组内下一条任务
            if request._decodeResponse?(this, data, response, error) ?? true {
                this.resume(session: session)
            } else {
                this.requests.removeAll(keepingCapacity: true)
            }
        }
        ongoingRequest = (task, request)
    }
    
    private func _complete(with error:NSError?) {
        progress.completedUnitCount += 1
        guard let handle = _completeHandle else { return }
        if Thread.isMainThread {
            handle(error)
        } else {
            DispatchQueue.main.async {
                handle(error)
            }
        }
    }

    func failureCancel(with error:Error) {
        queue.complete(group: self)
        _isInQueue = false
        _complete(with: error as NSError)
    }
    
    public func cancel() {
        var url:URL?
        if let (task, request) = ongoingRequest {
            url = request.url
            request.cancel(task: task)
            ongoingRequest = nil
        }
        
        if url == nil { url = requests.first?.url }
        
        requests.removeAll(keepingCapacity: true)
        
        let cancelled = NSLocalizedString("cancelled", comment: "已取消")
        
        // 构造一个和系统差不多的错误信息
        var info:[String : Any] = [NSLocalizedDescriptionKey:cancelled]
        
        if let http = url {
            info[NSURLErrorFailingURLErrorKey] = http
            info[NSURLErrorFailingURLStringErrorKey] = http.absoluteString
        }
        
        let error = NSError(domain: NSURLErrorDomain, code: -999, userInfo: info)

        failureCancel(with: error)
    }
    
    private var _isInQueue:Bool = false
    private var _completeHandle:((NSError?) -> Void)?
    public func onComplete(_ callback: @escaping (NSError?) -> Void) {
        _completeHandle = callback
        _isInQueue = true
        queue.groups.append(self)
        queue.resume()
    }
    
    lazy var sessionDelegate = NetSessionDelegate()
    
    deinit {
        print("组释放")
    }
}
