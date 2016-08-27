//
//  NotificationsManager.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-25.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth
import UIKit

class NotificationsManager {
    static let sharedInstance = NotificationsManager()
    private init() {}
    
    func sendNotification(toUserUids: [String], hasSound: Bool, groupId: String, message: String, deeplink: String){
        if let pushClient = BatchClientPush(apiKey: BATCH_API_KEY, restKey: BATCH_REST_KEY) {
            
                pushClient.sandbox = false
                if hasSound {
                    pushClient.customPayload = ["aps": ["badge": 1, "content-available": 1]]
                } else {
                    pushClient.customPayload = ["aps": ["badge": 1, "sound": NSNull(), "content-available": 1]]
                }
                pushClient.groupId = groupId
                pushClient.message.title = "Friendlies"
                pushClient.message.body = message
                pushClient.recipients.customIds = toUserUids
                pushClient.deeplink = deeplink
                
                pushClient.send { (response, error) in
                    if let error = error {
                        print("Something happened while sending the push: \(response) \(error.localizedDescription)")
                    } else {
                        print("Push sent \(response)")
                    }
                }
            
        } else {
            print("Error while initializing BatchClientPush")
        }
    }
    
    func createVoteNotification(post: Post, type: String){
        var message: String = ""
        var deeplink: String = ""
        print(post.authorUid)
        if type == "threads" {
            message = "\(post.numVoters) people have voted on your post \"\(post.text)\""
            deeplink = "eightam://votes/threads/\(post.threadKey)"
        } else {
            message = "\(post.numVoters) people have voted on your reply \"\(post.text)\""
            deeplink = "eightam://votes/replies/\(post.threadKey)"
        }
        let notification = Notification(uid: post.authorUid, threadKey: post.threadKey, message: message)
        notification.saveNotification()
        addValueToNotificationBadge(post.authorUid)
        sendNotification([post.authorUid], hasSound: false, groupId: "votes", message: message, deeplink: deeplink)
    }
    
    func createReplyNotification(uid: String, thread: Thread, threadReplies: [Post]){
        var uids: [String] = threadReplies.map({$0.authorUid}) //map all reply author uids to array
        uids.append(thread.authorUid)  //add OP uid to array
        uids = Array(Set(uids))   //filter to only unique uids
        uids = uids.filter({$0 != uid})       //filter out replier
        print(uids)
        let message = "Someone has replied to \"\(thread.originalPost.text)\""
        for uid in uids {
            let notification = Notification(uid: uid, threadKey: thread.key, message: message)
            notification.saveNotification()
            addValueToNotificationBadge(uid)
        }
        sendNotification(uids, hasSound: false, groupId: "replies", message: message, deeplink: "eightam://replies/\(thread.key)")
    }
    
    func addValueToNotificationBadge(uid: String){
        let firebase = FIRDatabase.database().reference()
        firebase.child("users").child(uid).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var user = currentData.value as? [String: AnyObject] {
                var notificationBadgeValue = user["notifications"] as? Int ?? 0
                notificationBadgeValue++
                user["notifications"] = notificationBadgeValue
                currentData.value = user
                return FIRTransactionResult.successWithValue(currentData)
            }
            return FIRTransactionResult.successWithValue(currentData)
            }, andCompletionBlock: { (error, committed, snapshot) in
                if error != nil {
                    print("error in transaction")
                }
        })
    }
    
    func getNumberOfUsersNotifications(uid: String, completion: (Int!)->()){
        let firebase = FIRDatabase.database().reference()
        firebase.child("users").child(uid).child("notifications").observeSingleEventOfType(.Value, withBlock: {snapshot in
            print(snapshot)
            let badgeValue = snapshot.value as? Int ?? nil
            completion(badgeValue)
        })
    }
    
    func updateTabBar(tabBarController: UITabBarController){
        print("update tab bar")
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            getNumberOfUsersNotifications(uid){ badgeValue in
                if badgeValue == nil {
                    tabBarController.tabBar.items?[NOTIFICATIONS_INDEX].badgeValue = nil
                } else {
                    tabBarController.tabBar.items?[NOTIFICATIONS_INDEX].badgeValue = "\(badgeValue)"
                }
            }
        }
    }
    
    func clearTabBarBadgeAtIndex(index: Int, tabBarController: UITabBarController){
        print("clear tab bar")
        if tabBarController.tabBar.items?[index].badgeValue != nil {
            print("tab bar is not nil")
            tabBarController.tabBar.items?[index].badgeValue = nil
            if let uid = FIRAuth.auth()?.currentUser?.uid {
                let firebase = FIRDatabase.database().reference()
                firebase.child("users").child(uid).child("notifications").setValue(nil)
            }
        }
    }
    
    func goToCertainView(deepLink: String, tabBarController: UITabBarController){
        print("go to certain view")
        let queryArray = deepLink.componentsSeparatedByString("/")
        let queryType = queryArray[2]
        var threadKey = ""
        if queryType == "replies" {
            threadKey = queryArray[3]
        } else {
            threadKey = queryArray[4]
        }
        tabBarController.selectedIndex = NOTIFICATIONS_INDEX
        if let notificationsNVC = tabBarController.viewControllers![NOTIFICATIONS_INDEX] as? UINavigationController {
            if let notificationsVC = notificationsNVC.viewControllers[0] as? NotificationsVC {
                let thread = Thread(key: threadKey)
                notificationsVC.threadSelected(thread)
                clearTabBarBadgeAtIndex(NOTIFICATIONS_INDEX, tabBarController: tabBarController)
            }
        }
    }
}