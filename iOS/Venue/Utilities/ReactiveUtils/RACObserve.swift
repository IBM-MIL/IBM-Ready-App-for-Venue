//
//  Created by Colin Eberhardt on 15/07/2014.
//  Copyright (c) 2014 Colin Eberhardt. All rights reserved.
//

// Pulled from http://www.scottlogic.com/blog/2014/07/24/mvvm-reactivecocoa-swift.html

import Foundation
import ReactiveCocoa

// replaces the RACObserve macro
func RACObserve(target: NSObject!, keyPath: String) -> RACSignal  {
  return target.rac_valuesForKeyPath(keyPath, observer: target)
}