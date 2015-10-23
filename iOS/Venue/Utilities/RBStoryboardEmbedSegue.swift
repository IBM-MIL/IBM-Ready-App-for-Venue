/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation

class RBStoryboardEmbedSegue : RBStoryboardSegue {
    override func perform() {
        let source = self.sourceViewController
        let destination = self.destinationViewController
        source.addChildViewController(destination)
        source.view.addSubview(destination.view)
        destination.didMoveToParentViewController(source)
    }
}