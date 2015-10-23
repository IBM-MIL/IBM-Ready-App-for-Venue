/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation

// Originated from https://gist.github.com/ijoshsmith/5e3c7d8c2099a3fe8dc3
extension Array {
    
    /**
    Randomizes the order of an array's elements in place
    */
    mutating func shuffle() {
        for _ in 0..<10 {
            sortInPlace { (_,_) in arc4random() < arc4random() }
        }
    }
}