/*
Licensed Materials - Property of IBM
© Copyright IBM Corporation 2015. All Rights Reserved.
*/

import UIKit
import CoreData
import Foundation

/**
*    Utility class to simulate the receiving and unlocking of alerts, invitations, and badges.
**/
class DemoManager: NSObject {
    
    // The in-app notification banner.
    static var notificationView: UIVisualEffectView!
    // A timer to track the removal of the notification banner.
    static var removeTimer: NSTimer!
    static var currentUser = UserDataManager.sharedInstance.currentUser
    
    /**
    Method to simulate sending the user an offer.
    */
    static func sendOffer() {
        let title = "20% Off Brick Cola"
        let message = "Just for you! Get 20% off all Coca Products at our various dining locations. Offer expires on 6/15/15. Use this code at the checkout: GJS7394F"
        sendLocalNotification(title, message: message)
        displayBanner(message)
        createNotification(title, message: message)
    }
    
    /**
    Method to simulate a weather alert.
    */
    static func weatherAlert() {
        let title = "Weather Alert: Thunderstorms Ahead"
        let message = "There is a 75% chance of thunderstorms starting at 3:30 PM. All major rides will be closed until it is safe to re-open. Please plan accordingly."
        sendLocalNotification(title, message: message)
        displayBanner(message)
        createNotification(title, message: message)
    }
    
    /**
    Method to simulate a wait time alert.
    */
    static func waitTimeAlert() {
        let title = "Low Wait Time: Tejas Twister"
        let message = "Make your move! The Tejas Twister's wait time is now 30 minutes or less."
        sendLocalNotification(title, message: message)
        displayBanner(message)
        createNotification(title, message: message)
    }
    
    /**
    Method to simulate receiving an invitation.
    */
    static func sendInvite() {
        let title = "Tori Thomas has Sent You An Invitation"
        let message = "Tori Thomas has invited you to the Brickland Bazaar."
        sendLocalNotification(title, message: message)
        displayBanner(message)
        
        // User ID 10 - Tori Thomas
        // POI ID 9 - Brickland Bazaar
        if let managedPOI = ApplicationDataManager.sharedInstance.fetchFromCoreData("POI", id: 9) {
            let poi = POI(managedPOI: managedPOI)
            ApplicationDataManager.sharedInstance.createInvitation(NSDate(), location: poi, recipients: [currentUser], from: 10)
        }
    }
    
    /**
    Method to simulate sending a reminder.
    */
    static func sendReminder() {
        let title = "Reminder: Andrew Jacobs Has Sent You An Invitation"
        let message = "Don’t forget! You’re meeting Andrew Jacobs at Bricks BBQ at 12:30 PM."
        sendLocalNotification(title, message: message)
        displayBanner(message)
        createNotification(title, message: message)
    }
    
    /**
    Method to simulate unlocking a badge.
    */
    static func unlockBadge() {
        // Stop badge from being unlocked more than once
        for task in UserDataManager.sharedInstance.currentUser.tasksCompleted {
            if task.id == 7 {
                return
            }
        }
        
        let title = "Congratulations! You've Earned A Badge"
        let message = "Badge Unlocked! You've earned the Coaster Champ badge, worth 900 points."
        sendLocalNotification(title, message: message)
        displayBanner(message)
        createNotification(title, message: message)
        
        // Update Task 7 - Brick Blaster to be completed.
        let task = ChallengeTask(id: 7, name: "Brick Blaster")
        UserDataManager.sharedInstance.currentUser.tasksCompleted.append(task)
        // Update Badge 2 - Coaster Champ to be completed.
        if let managedChallenge = ApplicationDataManager.sharedInstance.fetchFromCoreData("Challenge", id: 2) {
            let challenge = Challenge(managedChallenge: managedChallenge)
            UserDataManager.sharedInstance.currentUser.challengesCompleted.append(challenge)
        }
    }
    
    /**
    Method to display the in-app notification banner.
    
    - parameter message: The message to place in the banner.
    */
    static func displayBanner(message: String) {
        
        // guard against stacking banners
        guard notificationView == nil else {
            return
        }
        
        if let window = UIApplication.sharedApplication().keyWindow {
            
            let notificationFrame = CGRectMake(0, window.frame.origin.y - 80, window.frame.width, 80)
            notificationView = UIVisualEffectView(frame: notificationFrame)
            notificationView.effect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
            notificationView.backgroundColor = UIColor.clearColor()
            
            let labelFrame = CGRectMake(10, 0, notificationFrame.width - 20, notificationFrame.height)
            let messageLabel = UILabel(frame: labelFrame)
            messageLabel.textColor = UIColor.whiteColor()
            messageLabel.font = UIFont.systemFontOfSize(12.0)
            messageLabel.textAlignment = NSTextAlignment.Center
            messageLabel.lineBreakMode = NSLineBreakMode.ByTruncatingTail
            messageLabel.numberOfLines = 2
            messageLabel.text = message
            messageLabel.accessibilityActivate()
            messageLabel.accessibilityIdentifier = "notificationBannerLabel"
            
            notificationView.addSubview(messageLabel)
            
            let swipeGesture = UISwipeGestureRecognizer(target: self, action: "removeBannerFast")
            swipeGesture.direction = UISwipeGestureRecognizerDirection.Up
            
            notificationView.addGestureRecognizer(swipeGesture)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: "removeBannerFast")
            
            notificationView.addGestureRecognizer(tapGesture)
            
            window.addSubview(notificationView)
            UIView.animateWithDuration(0.5, animations: {
                self.notificationView.frame = CGRectOffset(self.notificationView.frame, 0, self.notificationView.frame.height)
            })
            removeTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "removeBannerSlow", userInfo: nil, repeats: false)
        }
    }
    
    /**
    Method to quickly remove the banner. Called when the banner is flicked up or tapped.
    */
    static func removeBannerFast() {
        UIView.animateWithDuration(0.2, animations: {
            self.notificationView.frame = CGRectOffset(self.notificationView.frame, 0, -self.notificationView.frame.height)
            }, completion: {(done: Bool) in
                if done {
                    self.removeBanner()
                }
        })
    }
    
    /**
    Method to slowly remove the banner. Called when the banner timer expires.
    */
    static func removeBannerSlow() {
        UIView.animateWithDuration(0.5, animations: {
            self.notificationView.frame = CGRectOffset(self.notificationView.frame, 0, -self.notificationView.frame.height)
            }, completion: {(done: Bool) in
                if done {
                    self.removeBanner()
                }
        })
    }
    
    /**
    Method to remove the banner.
    */
    static func removeBanner() {
        self.notificationView.removeFromSuperview()
        self.notificationView = nil
        self.removeTimer.invalidate()
    }
    
    /**
    Method to create and store a new notification.
    
    - parameter title:   The title of the notification.
    - parameter message: The message in the notification.
    */
    static func createNotification(title: String, message: String) {
        
        guard let managedNotification = ApplicationDataManager.sharedInstance.createManagedObject("Notification") else {
            return
        }
        
        managedNotification.setValue(Int(arc4random_uniform(1000))+1000, forKey: "id")
        managedNotification.setValue(title, forKey: "title")
        managedNotification.setValue(message, forKey: "message")
        managedNotification.setValue(true, forKey: "unread")
        managedNotification.setValue("alert", forKey: "type")
        managedNotification.setValue(NSDate(), forKey: "timestamp")
        
        ApplicationDataManager.sharedInstance.saveToCoreData()
        let notification = Notification(managedNotification: managedNotification)
        UserDataManager.sharedInstance.currentUser.notificationsRecieved.append(notification)
        
    }
    
    /**
    Method to send a local notification to be displayed in the notification center or when the app is backgrounded.
    
    - parameter title:   The title of the notification.
    - parameter message: The message in the notification.
    */
    static private func sendLocalNotification(title: String, message: String) {
        let notification = UILocalNotification()
        if #available(iOS 8.2, *) {
            notification.alertTitle = title
        }
        notification.alertBody = message
        notification.fireDate = NSDate()
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

}
