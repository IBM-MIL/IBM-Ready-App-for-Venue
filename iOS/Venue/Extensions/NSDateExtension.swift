/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import Foundation

extension NSDate {
    
    /**
    Simple date method to determine a localized time based on a user's locale
    
    - returns: a localized date in a String
    */
    func localizedStringTime() -> String {
        return NSDateFormatter.localizedStringFromDate(self, dateStyle: NSDateFormatterStyle.NoStyle, timeStyle: NSDateFormatterStyle.ShortStyle)
    }
    
}