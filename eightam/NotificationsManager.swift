//
//  NotificationsManager.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-25.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import Foundation

class NotificationsManager {
    static let sharedInstance = NotificationsManager()
    private init() {}
    
    func sendNotification(toUserUid: String, hasSound: Bool, groupId: String, message: String, deeplink: String){
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
                pushClient.recipients.customIds = [toUserUid]
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
}