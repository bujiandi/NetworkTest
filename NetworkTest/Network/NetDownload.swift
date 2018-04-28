//
//  NetDownload.swift
//  NetworkTest
//
//  Created by 慧趣小歪 on 2018/4/23.
//  Copyright © 2018年 慧趣小歪. All rights reserved.
//

import Foundation

open class NetDownloadRequest : NetRequest {
    
    public var progress:Progress
    
    var _localURL:URL?
    
    public var localURL:URL {
        if let local = _localURL { return local }
        let fileName = url.lastPathComponent
        let encoder:NetEncoder = _encoder ?? Net.defaultEncoder
        let getURL = encoder.url(forRequest: self, withGetParams: _getParams)
        let bookmarkPath = Net.bookmarkPathFor(key: getURL.absoluteString)
        let bookmarkURL = URL(fileURLWithPath: bookmarkPath, isDirectory: true)
        let fileURL = bookmarkURL.appendingPathComponent(fileName, isDirectory: false)
        return fileURL
    }
    
    public init(request:NetRequest, local:URL? = nil) {
        progress = Progress(totalUnitCount: 0, parent: request.group.progress, pendingUnitCount: 0)
        _localURL = local
        
        super.init(group: request.group, url: request.url)
        progress.isCancellable = true
        progress.cancellationHandler = { [weak self] in self?.cancel() }
        progress.isPausable = true
        progress.pausingHandler = { [weak self] in self?.cancel() }
        
        _postParams = request._postParams
        _getParams = request._getParams
        _headers = request._headers
        _encoder = request._encoder
        _timeout = request._timeout
        _policy = request._policy
    }
    
    var _progress:((Progress) -> Void)?
    public func onProgressChanged(_ handler: @escaping (Progress) -> Void) -> Self {
        _progress = handler
        return self
    }
    func onProgress(totalSize:Int64, localSize:Int64) {
        progress.totalUnitCount = totalSize
        progress.completedUnitCount = localSize
        _progress?(progress)
    }

    override func resumeTask(session:URLSession, _ onComplete: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask {
        let task = session.dataTask(with: urlRequest)
        _complete = onComplete
        task.resume()
        return task
    }
    
    func onComplete(_ data:Data?, _ response:URLResponse?, _ error:Error?) {
        _complete?(data, response, error)
    }
    var _complete:((Data?, URLResponse?, Error?) -> Void)?
}


private var KEY_NET_WEAK_REQUEST:String = "net.weak.request"
private var KEY_NET_WEAK_REQUEST_OBJ:String = "net.weak.request.obj"


private class WeakObject {
    weak var obj:NSObject?
    
    deinit {
        guard let item = obj else { return }
        objc_setAssociatedObject(item, &KEY_NET_WEAK_REQUEST, nil, .OBJC_ASSOCIATION_ASSIGN)
    }
}
internal extension URLSessionTask {
    
    /// netRequest is weak property
    internal var netRequest:NetRequest? {
        get {
            return objc_getAssociatedObject(self, &KEY_NET_WEAK_REQUEST) as? NetRequest
        }
        set {
            objc_setAssociatedObject(self, &KEY_NET_WEAK_REQUEST, newValue, .OBJC_ASSOCIATION_ASSIGN)
            // 定义一个跟随对象绑定到 目标, 当目标释放时 , 利用绑定对象的析构函数将属性设为nil
            if let v = newValue {
                let weakObj:WeakObject = objc_getAssociatedObject(v, &KEY_NET_WEAK_REQUEST_OBJ) as? WeakObject ?? WeakObject()
                weakObj.obj = self
                objc_setAssociatedObject(v, &KEY_NET_WEAK_REQUEST_OBJ, weakObj, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        }
    }
    
}
