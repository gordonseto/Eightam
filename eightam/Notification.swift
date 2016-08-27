//
//  Notification.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-27.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Notification {
 
    private var _message: String!
    private var _threadKey: String!
    private var _uid: String!
    
    var uid: String! {
        return _uid
    }
    
    var message: String! {
        return _message
    }
    
    var threadKey: String! {
        return _threadKey
    }
    
    var firebase: FIRDatabaseReference!
    
    init(uid: String, threadKey: String, message: String) {
        _uid = uid
        _threadKey = threadKey
        _message = message
    }
    
    func saveNotification(){
        guard let uid = _uid else { return }
        guard let message = _message else { return }
        guard let threadKey = _threadKey else { return }
        
        let notification = ["threadKey": threadKey, "message": message]
        
        firebase = FIRDatabase.database().reference()
        firebase.child("notifications").child(uid).childByAutoId().setValue(notification)
    }
}