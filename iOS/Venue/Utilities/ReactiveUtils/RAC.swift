//
//  Created by Colin Eberhardt on 15/07/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//

// Pulled from http://www.scottlogic.com/blog/2014/07/24/mvvm-reactivecocoa-swift.html

import Foundation
import ReactiveCocoa

// a struct that replaces the RAC macro
struct RAC  {
    var target: NSObject
    var keyPath: String
    var nilValue: AnyObject?
    
    init(_ target: NSObject, _ keyPath: String, nilValue: AnyObject? = nil) {
        self.target = target
        self.keyPath = keyPath
        self.nilValue = nilValue
    }
    
    func assignSignal(signal : RACSignal) -> RACDisposable {
        return signal.setKeyPath(self.keyPath, onObject: self.target, nilValue: self.nilValue)
    }
}


infix operator <~ {
associativity right
precedence 93
}

func <~ (rac: RAC, signal: RACSignal) -> RACDisposable {
    return signal ~> rac
}

func ~> (signal: RACSignal, rac: RAC) -> RACDisposable {
    return rac.assignSignal(signal)
}