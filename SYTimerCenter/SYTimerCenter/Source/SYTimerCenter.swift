//
//  SYTimerCenter.swift
//  SYTimerCenter
//
//  Created by wangshiyu13 on 2017/2/22.
//  Copyright © 2017年 wangshiyu13. All rights reserved.
//

import Foundation

public final class SYTimerCenter {
    
    public final class SYTimer: Hashable {
        public static func ==(lhs: SYTimerCenter.SYTimer, rhs: SYTimerCenter.SYTimer) -> Bool {
            return lhs.hashValue == rhs.hashValue
        }

        
        fileprivate let timer : DispatchSourceTimer
        
        fileprivate var tcount = 0
        
        /// Hash值
        public var hashValue : Int {
            get {
                return self.timer.hash
            }
        }
        
        /// 是否正在运行
        public var isRunning: Bool = false
        
        /**
         创建HLTimer
         
         - parameter ti:           间隔时间
         - parameter afterTime:    延迟时间
         - parameter repeatsCount: 循环次数
         - parameter repeats:      是否永久循环
         - parameter handler:      回调，默认在主线程
         
         - returns: HLTimer对象
         */
        init(_ ti: DispatchTimeInterval, _ afterTime: DispatchTimeInterval, _ execQueue: DispatchQueue, _ repeatsCount: Int, _ repeats: Bool, handler: @escaping () -> ()) {
            timer = DispatchSource.makeTimerSource(flags:[], queue: execQueue)
            timer.scheduleRepeating(wallDeadline: .now() + afterTime, interval: ti, leeway: .seconds(0))
            timer.setEventHandler {
                if Thread.isMainThread {
                    handler()
                } else {
                    DispatchQueue.main.async {
                        handler()
                    }
                }
                self.tcount += 1
                if self.tcount == (repeats ? Int.max : repeatsCount) {
                    self.cancel()
                }
            }
        }
        
        /**
         暂停Timer
         */
        public func suspend() {
            timer.suspend()
            isRunning = false
        }
        
        /**
         取消Timer
         */
        public func cancel() {
            timer.cancel()
        }
        
        /**
         启动Timer
         */
        public func resume() {
            timer.resume()
            isRunning = true
        }
    }
    
    public static let `default` = SYTimerCenter()
    
    fileprivate(set) var queue = Set<SYTimer>()
    
    /**
     创建Timer并添加进TimerCenter
     
     - parameter ti:           间隔时间
     - parameter afterTime:    延迟时间按
     - parameter repeatsCount: 循环次数
     - parameter repeats:      是否一直循环
     - parameter autoPlay:     是否自动执行
     - parameter handler:      Timer回调，回调默认在主线程
     
     - returns: 返回Timer对象
     */
    @discardableResult
    public func createTimer(_ ti: DispatchTimeInterval, afterTime: DispatchTimeInterval = .seconds(0), _ execQueue: DispatchQueue = DispatchQueue.main, repeatsCount: Int = 1, repeats: Bool = false, autoPlay: Bool = true, handler: @escaping ()->()) -> SYTimer {
        let timer = SYTimer(ti, afterTime, execQueue, repeatsCount, repeats, handler: handler)
        addTimer(timer, autoPlay: autoPlay)
        return timer
    }
    
    /**
     添加Timer
     
     - parameter timer:    Timer对象
     - parameter autoPlay: 是否自动执行
     */
    public func addTimer(_ timer: SYTimer, autoPlay: Bool = true) {
        if !queue.contains(timer) {
            queue.insert(timer)
            if autoPlay { timer.resume() }
        }
    }
    
    /**
     移除Timer
     
     - parameter timer: 需要移除的Timer对象
     */
    public func removeTimer(_ timer: SYTimer) {
        queue.remove(timer)
        timer.cancel()
    }
    
    fileprivate init() {
        NotificationCenter.default.addObserver(self, selector: #selector(awakeAllTimer), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(sleepAllTimer), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func sleepAllTimer() {
        queue.forEach {
            if $0.isRunning { $0.suspend() }
        }
    }
    
    @objc func awakeAllTimer() {
        queue.forEach {
            if !$0.isRunning { $0.resume() }
        }
    }
}
