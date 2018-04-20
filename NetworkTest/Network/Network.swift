//
//  Network.swift
//  NetworkTest
//
//  Created by 慧趣小歪 on 2018/4/19.
//  Copyright © 2018年 慧趣小歪. All rights reserved.
//

import Foundation



public struct Net {
    
    public static var defaultQueue = NetQueue()
    
    public static var jsonEncoder = NetJSONEncoder()
    public static var paramsEncoder = NetParamsEncoder()
    public static var uploadEncoder = NetUploadEncoder()
    
    public static func http(_ createGroup: (NetGroup) -> Void) -> NetGroup {
        return defaultQueue.http(createGroup)
    }
    
}
