//
//  main.swift
//  NetworkTest
//
//  Created by 慧趣小歪 on 2018/4/19.
//  Copyright © 2018年 慧趣小歪. All rights reserved.
//

import Foundation

RunLoop.current.run()


Net.http { (group) in
    group.request(URL(string: "http://www.baidu.com/")!)
        .onSuccess { (response) in
            response
        }
    
}
