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
    
    deinit {
        print("请求释放:\(url)")
    }
 
    public unowned let group:NetGroup
    public let url:URL
    
    var _policy:URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
    public var policy:URLRequest.CachePolicy { return _policy }
    
    var _timeout:TimeInterval? = nil
    public var timeout:TimeInterval { return _timeout ?? Net.timeout }

    public var queue:NetQueue { return group.queue }

    public init(group:NetGroup, url:URL) {
        self.group = group
        self.url = url
    }
    
    var _postParams:[(String, () -> Any)] = []
    var _getParams:[(String, () -> Any)] = []
    var _headers:[String:String] = [:]
    var _encoder:NetEncoder?
    
    public func params(encoder:NetEncoder) -> Self {
        _encoder = encoder
        return self
    }
    
    public func param(post key:String, value closure: @autoclosure () -> Any) -> Self {
        let value = closure()
        return param(post: key, closure: { value })
    }
    public func param(post key:String, closure: @escaping () -> Any) -> Self {
        _postParams.append((key, closure))
        return self
    }
    
    public func param(get key:String, value closure: @autoclosure () -> Any) -> Self {
        let value = closure()
        return param(get: key, closure: { value })
    }
    public func param(get key:String, closure: @escaping () -> Any) -> Self {
        _getParams.append((key, closure))
        return self
    }
    
    public func header(key:String, value closure: @autoclosure () -> String) -> Self {
        _headers[key] = closure()
        return self
    }
    
    public func cachePolicy(_ policy:URLRequest.CachePolicy) -> Self {
        _policy = policy
        return self
    }
    
    public func autoFailureAfter(timeout:TimeInterval) -> Self {
        if timeout > 0 { _timeout = timeout }
        return self
    }
    
    public func cancel() {
        group.cancel()
    }
    
    public var urlRequest:URLRequest {
        
        let encoder:NetEncoder = _encoder ?? Net.defaultEncoder
        var url = self.url
        
        if _getParams.count > 0 {
            url = encoder.url(forRequest: self, withGetParams: _getParams)
        }
        
        var request = URLRequest(url: url, cachePolicy: policy, timeoutInterval: timeout)
        
        if _postParams.count > 0 {
            
            var params = _postParams.map { ($0.0, $0.1() ) }
            encoder.encode(request: self, params: &params)
            let value:String = encoder.value(params).joined(separator: "&")
            let data = value.data(using: .utf8)!
            
            request.httpMethod = "POST"
            request.httpBody = data
            request.addValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        } else {
            request.httpMethod = "GET"
        }
        
        // 如果有自定义 头信息
        for (key, value) in _headers where !key.isEmpty {
            request.addValue(value, forHTTPHeaderField: key)
        }
        
        // Accept-Encoding HTTP Header; see https://tools.ietf.org/html/rfc7230#section-4.2.3
        if _headers["Accept-Encoding"] == nil {
            request.addValue("gzip;q=1.0, compress;q=0.5", forHTTPHeaderField: "Accept-Encoding")
        }
        
        // Accept-Language HTTP Header; see https://tools.ietf.org/html/rfc7231#section-5.3.5
        if _headers["Accept-Language"] == nil {
            request.addValue(Net.acceptLanguage, forHTTPHeaderField: "Accept-Language")
        }
        
        if _headers["User-Agent"] == nil {
            request.addValue(Net.userAgent, forHTTPHeaderField: "User-Agent")
        }
        
        return request
    }
    
    func resumeTask(session:URLSession, _ onComplete: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask {
        
        let task = session.dataTask(with: urlRequest) {
            (data:Data?, response:URLResponse?, error:Error?) in
            onComplete(data, response, error)
        }
        task.resume()
        return task
    }
    
    var _decodeResponse:((NetGroup, Data?, URLResponse?, Error?) -> Bool)?
}

open class NetDataRequest : NetRequest {
    
    /// 转为上传请求
    public func upload(_ formClosure: (NetUploadForm) -> Void) -> NetUploadRequest {
        let form = NetUploadForm()
        let request = NetUploadRequest(request: self, form: form)
        formClosure(form)
        return request
    }
    
    /// 转为下载请求
    public func download(to localURL:URL) -> NetDownloadRequest {
        return NetDownloadRequest(request: self, local: localURL)
    }
    
    /// 转为下载请求
    public func download(to localPath:String) -> NetDownloadRequest {
        return download(to: URL(fileURLWithPath: localPath))
    }
    
    /// 转为下载请求
    public func downloadToCache() -> NetDownloadRequest {
        return NetDownloadRequest(request: self)
    }
}


extension NetSuccessable where Self : NetRequest {
    
    @discardableResult
    public func onSuccess<T:NetDecoder>(decoder:T, _ callback: @escaping (T.Result) -> Void) -> Self where Self == T.Request {
        
        _decodeResponse = { [unowned self]
            (group:NetGroup, data:Data?, response:URLResponse?, netErr:Error?) in
            
            // 如果不是HTTP响应
            guard let httpRes  = response as? HTTPURLResponse,
                  let httpData = data else
            {
                group.failureCancel(with: netErr!)
                return false
            }
            
            // 如果状态码异常
            if !(200..<300).contains(httpRes.statusCode) {
                let code = httpRes.statusCode
                let text = (netErr as NSError?)?.domain ?? "网络错误[\(code)]"
                let err = NSError(domain: text, code: code, userInfo: ["response":httpRes])
                group.failureCancel(with: err)
                return false
            }
            
            // 如果如果成功解析
            do {
                callback(try decoder.decode(request: self, response: httpRes, data: httpData))
            } catch {
                group.failureCancel(with: error)
                return false
            }
            return true
        }
        group.append(self)
        return self
    }
}

extension NetRequest : NetSuccessable {}
