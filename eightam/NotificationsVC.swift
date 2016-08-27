//
//  NotificationsVC.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-27.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class NotificationsVC: UIViewController {

    var firebase: FIRDatabaseReference!
    
    var notifications: [Notification] = []
    
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let uid = FIRAuth.auth()?.currentUser?.uid {
            self.uid = uid
            getNotifications()
        }
    }
    
    func getNotifications(){
        firebase =  FIRDatabase.database().reference()
        firebase.child("notifications").child(uid).queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: {snapshot in
            self.notifications = []
            for child in snapshot.children {
                let threadKey = child.value!["threadKey"] as? String ?? ""
                let message = child.value!["message"] as? String ?? ""
                print(message)
                let notification = Notification(uid: self.uid, threadKey: threadKey, message: message)
                self.notifications.append(notification)
            }
            print(self.notifications)
        })
    }


}
