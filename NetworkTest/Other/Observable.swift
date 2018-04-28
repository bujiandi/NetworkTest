//
//  Observable.swift
//  Tools
//
//  Created by Steven on 2017/9/19.
//
//

import Foundation

fileprivate struct Observer<T> {
    
    weak var target : AnyObject?
    var notice : Notice?
    
    var action : Selector?
    
    
    typealias Notice = (_ new: T, _ old: T) -> Void
    
    init(_ target: AnyObject, _ notice: @escaping Notice) {
        self.target = target
        self.notice = notice
    }
    
    init(_ target: AnyObject, _ action: Selector) {
        self.target = target
        self.action = action
    }
}


open class Observable<T> {
    
    public typealias Notice = (_ new: T, _ old: T) -> Void
    
    private var observers : [Observer<T>] = []
    
    open var value : T {
        didSet{
            func filterNotice() {
                observers = observers.filter {
                    guard let target = $0.target else { return false }
                    if let action = $0.action {
                        target.perform(action, with: value, with: oldValue).releaseIfNotVoid()
                    }
                    $0.notice?(value, oldValue)
                    return true
                }
            }
            
            if Thread.current.isMainThread {
                filterNotice()
            } else {
                DispatchQueue.main.sync(execute: filterNotice)
            }
        }
    }
    
    public init(_ v : T) { value = v }
    
    public func addNotice(target: AnyObject, notice: @escaping Notice, igoreInit:Bool = false) {
        observers.append(Observer(target, notice))
        if !igoreInit { notice(value, value) }
    }
    
    public func addNotice(target: AnyObject, action: Selector, igoreInit:Bool = false){
        observers.append(Observer(target, action))
        if !igoreInit {
            target.perform(action, with: value, with: value).releaseIfNotVoid()
        }
    }
    
    public func removeNotice(target: AnyObject){
        observers = observers.filter{
            $0.target !== target && $0.target != nil
        }
    }
    
}

extension Observable where T == Bool {
    
    public func changeValue() {
        value = !value
    }
    
}

