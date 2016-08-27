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
            deeplink = "eightam://votes/threads/\(post.key)"
        } else {
            message = "\(post.numVoters) people have voted on your reply \"\(post.text)\""
            deeplink = "eightam://votes/replies/\(post.key)"
        }
        sendNotification([post.authorUid], hasSound: false, groupId: "votes", message: message, deeplink: deeplink)
    }
    
    func createReplyNotification(uid: String, thread: Thread, threadReplies: [Post]){
        var uids: [String] = threadReplies.map({$0.authorUid}) //map all reply author uids to array
        uids.append(thread.authorUid)  //add OP uid to array
        uids = Array(Set(uids))   //filter to only unique uids
        uids = uids.filter({$0 != uid})       //filter out replier
        print(uids)
        sendNotification(uids, hasSound: false, groupId: "replies", message: "Someone has replied to \"\(thread.originalPost.text)\"", deeplink: "eightam://replies/\(thread.key)")
    }
}