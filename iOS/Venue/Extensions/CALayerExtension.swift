/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation

extension CALayer {
    
    func resizeImmediatly(frame: CGRect) {
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(0)
        CATransaction.setDisableActions(true)
        self.frame = frame
        CATransaction.commit()
        
    }
    
}