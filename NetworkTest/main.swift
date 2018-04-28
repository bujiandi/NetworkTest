//
//  main.swift
//  NetworkTest
//
//  Created by 慧趣小歪 on 2018/4/19.
//  Copyright © 2018年 慧趣小歪. All rights reserved.
//

import Foundation

let url:URL = "http://www.baidu.com/download/book.png?kslkjflla=123"

let rrr = URL.init(string: "https://www.yunchengj.net/down/price.png", relativeTo: url)!

print(url.lastPathComponent, rrr.absoluteString, rrr)


class DataResult {
    var html:String
    
    init(_ html:String) {
        self.html = html
    }
    
    deinit {
        print("DataResult 已释放")
    }
}

class Book {
    
    
    func requestBaidu() {
        var result:DataResult?
        Net.http {
            $0.request(URL(string: "http://m.baidu.com/")!)
                .onSuccess(decoder:  NetHTMLDecoder(), { (html) in
                    result = DataResult(html)
                })
            }.onComplete {
                if let error = $0 {
                    print("Book 失败:",error.localizedDescription)
                } else {
                    print("成功 result:\(String(describing: result))")
                }
//                result = nil
        }
        
    }
    
}
Net.defaultQueue.concurrentlyCount = 2

var book:Book? = Book()

book?.requestBaidu()


//
//
//Net.http {
//    $0.request(URL(string: "http://www.baidu.com/")!)
//        .onSuccess(decoder: NetHTMLDecoder()) { (html) in
//            print("www 成功")
//    }
//    $0.request(URL(string: "http://s.baidu.com/")!)
//        .onSuccess(decoder: NetHTMLDecoder()) { (html) in
//            print("s 成功")
//    }
//    $0.request(URL(string: "http://m.baidu.com/")!)
//        .onSuccess(decoder: NetHTMLDecoder()) { (html) in
//            print("m 成功")
//    }
//    }.onComplete {
//        if let error = $0 {
//            print(error.code, error.localizedDescription)
//        } else {
//            print("访问成功")
//        }
//}
//
//Net.http {
//    $0.request(URL(string: "http://www.baidu.com/")!)
//        .onSuccess(decoder: NetHTMLDecoder()) { (html) in
//            print("www 成功")
//    }
//    $0.request(URL(string: "http://m.baidu.com/")!)
//        .param(post: "231", value: 2)
//        .param(post: "note", value: 1)
//        .param(post: "flower") { "123" }
//        .onSuccess(decoder: NetHTMLDecoder()) { (html) in
//            print("m 成功")
//    }
//    $0.request(URL(string: "http://s.baidu.com/")!)
//        .onSuccess(decoder: NetHTMLDecoder()) { (html) in
//            print("s 成功")
//    }
//    }.onComplete {
//        if let error = $0 {
//            print(error.code, error.localizedDescription)
//        } else {
//            print("访问成功")
//        }
//}

DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    book = nil

    Net.http {
        $0.request(URL(string: "https://f11.baidu.com/it/u=1882878358,2856985097&fm=173&app=25&f=JPEG?w=624&h=419&s=359B7B954BBEC8CA58F9EDDA03008033&access=215967316")!)
            .downloadToCache()
            .onProgressChanged {
                print( Double($0.completedUnitCount) / Double($0.totalUnitCount) )
            }
            .onSuccess(decoder: NetDownDecoder(), { (data) in
                
            })
        }.onComplete({
            if let error = $0 {
                print(error.code, error.localizedDescription)
            } else {
                print("访问成功")
            }
        })
}

RunLoop.current.run()
