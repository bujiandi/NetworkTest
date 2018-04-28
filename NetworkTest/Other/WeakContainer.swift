//
//  WeakContainer.swift
//  Tools
//
//  Created by 慧趣小歪 on 2017/8/8.
//
//

import Foundation



public protocol ContainerType:class {
    
    associatedtype Element
    
    var obj:Element? { get set }
    
    init(_ obj:Element)
}

open class StrongContainer<T:AnyObject> : ContainerType {
    
    public typealias Element = T
    
    open var obj: Element?
    
    public required init(_ obj: Element) {
        self.obj = obj
    }

}

open class WeakContainer<T:AnyObject> : ContainerType {
    
    public typealias Element = T
    
    weak open var obj:Element?
    
    public required init(_ obj:Element) {
        self.obj = obj
    }
    
}
