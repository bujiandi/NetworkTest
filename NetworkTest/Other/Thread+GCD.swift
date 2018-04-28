//
//  Array+Utils.swift
//
//  Created by bujiandi(慧趣小歪) on 14/10/4.
//

import Foundation

public struct DispatchHelper {
    
    public let queue:DispatchQueue
    
    public init(_ queue:DispatchQueue) {
        self.queue = queue
    }
    
    public func asyncMain(execute work: @escaping @convention(block) () -> Void) {
        DispatchQueue.main.async(execute: work)
    }
    
    public func syncMain(execute work: @escaping @convention(block) () -> Void) {
        DispatchQueue.main.sync(execute: work)
    }
}

extension DispatchQueue {
    
    public func asyncHelper(execute work: @escaping @convention(block) () -> Void) -> DispatchHelper {
        
        var helper:DispatchHelper? = DispatchHelper(self)
        async {
            work()
            helper = nil
        }
        return helper!
    }
    
}
