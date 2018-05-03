//
//  Observable.swift
//  Tools
//
//  Created by Steven on 2017/9/19.
//
//

import Foundation

public struct ListenerNotice<T> {
    
    fileprivate var observer : Observer<T>
    fileprivate var value : T
    
    fileprivate init(_ observer:Observer<T>, _ value:T) {
        self.observer = observer
        self.value = value
    }
    
    public func initValue() {
        observer.notice(value, value)
    }
}


fileprivate struct Observer<T> {
    
    weak var target : AnyObject?
    var notice : Notice
    
    typealias Notice = (_ new: T, _ old: T) -> Void
    
    init(_ target: AnyObject, _ notice: @escaping Notice) {
        self.target = target
        self.notice = notice
    }
    
    init(_ target: AnyObject, _ action: Selector, _ needRelease:Bool = false) {
        self.target = target
        self.notice = { [weak target] (newValue:T, oldValue:T) in
            if needRelease {
                target?.perform(action, with: newValue, with: oldValue).release()
            } else {
                _ = target?.perform(action, with: newValue, with: oldValue)
            }
        }
    }
    
}


/// 数据监听器
open class Listener<T> {
    
    public typealias Notice = (_ new: T, _ old: T) -> Void
    
    private var observers : [Observer<T>] = []
    
    open var value : T {
        didSet{
            
            let filterNotice:() -> Void = { [unowned self] in
                self.observers = self.observers.filter {
                    if $0.target == nil { return false }
                    $0.notice(self.value, oldValue)
                    return true
                }
            }
//            func filterNotice() {
//                observers = observers.filter {
//                    if $0.target == nil { return false }
//                    $0.notice(value, oldValue)
//                    return true
//                }
//            }
            
            if Thread.current.isMainThread {
                filterNotice()
            } else {
                DispatchQueue.main.sync(execute: filterNotice)
            }
        }
    }
    
    public init(_ v : T) { value = v }
    
    public func removeNotice(target: AnyObject){
        observers = observers.filter {
            $0.target !== target && $0.target != nil
        }
    }
    
    @discardableResult
    public func addNotice(target: AnyObject, notice: @escaping Notice) -> ListenerNotice<T> {
        let observer = Observer<T>(target, notice)
        observers.append(observer)
        return ListenerNotice<T>(observer, value)
    }
    
    @discardableResult
    public func addNotice(target: AnyObject, action: Selector, needRelease:Bool = false) -> ListenerNotice<T> {
        let observer = Observer<T>(target, action, needRelease)
        observers.append(observer)
        return ListenerNotice<T>(observer, value)
    }
    
}

extension Listener where T == Bool {
    
    public func changeValue() {
        
        value = !value
    }
    
}

