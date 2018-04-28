//
//  NetUpload.swift
//  NetworkTest
//
//  Created by 慧趣小歪 on 2018/4/23.
//  Copyright © 2018年 慧趣小歪. All rights reserved.
//

import Foundation

let newLineCRLF = "\r\n".data(using: .utf8)!

open class NetUploadForm {
    
    //fenfen.boundary.%08x%08x
    //Boundary+%08X%08X
    fileprivate lazy var boundary:String = String(format: "fenfen.net.boundary.%08x%08x", arc4random(), arc4random())
    
    fileprivate lazy var data = Data()
    
    public func append(data:Data) {
        self.data.append("--\(boundary)")
        self.data.append(newLineCRLF)
        self.data.append("Content-Disposition: form-data")
        self.data.append(newLineCRLF)
        
        self.append(data)
    }
    
    public func append(data:Data, name:String) {
        self.data.append("--\(boundary)")
        self.data.append(newLineCRLF)
        self.data.append("Content-Disposition: form-data; name=\"\(name)\"")
        self.data.append(newLineCRLF)
        
        self.append(data)
    }
    
    public func append(data:Data, name:String, fileName:String, mimeType:String) {
        
        let mime = mimeType.isEmpty ? "application/octet-stream" : mimeType
        
        self.data.append("--\(boundary)")
        self.data.append(newLineCRLF)
        self.data.append("Content-Disposition: form-data; name=\"\(name)\"; filename=\"\(fileName)\"")
        self.data.append(newLineCRLF)
        self.data.append("Content-Type: \(mime)")
        self.data.append(newLineCRLF)
        
        self.append(data)
    }
    
    internal func append(_ saveData:Data) {
        data.append(newLineCRLF)    //正文前另起一行
        data.append(saveData)
        data.append(newLineCRLF)    //结束另起一行
    }

}

open class NetUploadRequest : NetRequest {
    
    private var _form:NetUploadForm
    public var form:NetUploadForm { return _form }
    
    public init(request:NetRequest, form:NetUploadForm) {
        _form = form
        super.init(group: request.group, url: request.url)
        _postParams = request._postParams
        _getParams = request._getParams
        _headers = request._headers
        _encoder = request._encoder
        _timeout = request._timeout
        _policy = request._policy
    }
    
    public override var urlRequest: URLRequest {
        
        let encoder:NetEncoder = _encoder ?? Net.defaultEncoder
        var url = self.url
        
        if _getParams.count > 0 {
            url = encoder.url(forRequest: self, withGetParams: _getParams)
        }
        
        var request = URLRequest(url: url, cachePolicy: policy, timeoutInterval: timeout)
        
        var data = _form.data
        
        if !_postParams.isEmpty {

            var params = _postParams.map { ($0.0, $0.1() ) }
            encoder.encode(request: self, params: &params)

            for (key, value) in params {
                let val = unwrapOptionalToString(value)
                data.append("--\(_form.boundary)")
                data.append(newLineCRLF)
                data.append("Content-Disposition: form-data; name=\"\(key)\"")
                data.append(newLineCRLF)
                data.append(val)
            }
        }
        data.append("--\(_form.boundary)--")
        data.append(newLineCRLF)

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
        
        request.httpMethod = "POST"
        request.httpBody = data
        request.addValue("\(data.count)", forHTTPHeaderField: "Content-Length")
        request.addValue("multipart/form-data; boundary=\(_form.boundary)", forHTTPHeaderField: "Content-Type")
        
        return request
    }
    
    override func resumeTask(session: URLSession, _ onComplete: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionTask {
        
        let request = urlRequest
        
        let task = session.uploadTask(with: request, from: request.httpBody!) {
            (data:Data?, response:URLResponse?, error:Error?) in
            onComplete(data, response, error)
        }
        task.resume()
        return task

    }
    
}

//public func unwrapOptionalToString<T>(_ v:T?) -> String {
//    var val:String!
//    guard let value = v else { return "" }
//    
//    let mirror = Mirror(reflecting: value)
//    if mirror.displayStyle == .optional {
//        let children = mirror.children
//        if children.count == 0 {
//            val = ""
//        } else {
//            val = "\(children[children.startIndex].value)"
//        }
//    } else {
//        val = "\(value)"
//    }
//    
//    return val
//}

