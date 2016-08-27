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
    private var _seen: Bool!
    private var _time: NSTimeInterval!
    
    var uid: String! {
        return _uid
    }
    
    var message: String! {
        return _message
    }
    
    var threadKey: String! {
        return _threadKey
    }
    
    var seen: Bool! {
        get {
            return _seen
        }
        set {
            _seen = newValue
        }
    }
    
    var time: NSTimeInterval! {
        return _time
    }
    
    var firebase: FIRDatabaseReference!
    
    init(uid: String, threadKey: String, message: String){
        _uid = uid
        _threadKey = threadKey
        _message = message
        _seen = false
        _time = NSDate().timeIntervalSince1970
    }
    
    init(uid: String, threadKey: String, message: String, seen: Bool, time: NSTimeInterval) {
        _uid = uid
        _threadKey = threadKey
        _message = message
        _seen = seen
        _time = time
    }
    
    func saveNotification(){
        guard let uid = _uid else { return }
        guard let message = _message else { return }
        guard let threadKey = _threadKey else { return }
        guard let time = _time else { return }
        
        let notification = ["threadKey": threadKey, "message": message, "time": time]
        
        firebase = FIRDatabase.database().reference()
        firebase.child("notifications").child(uid).childByAutoId().setValue(notification)
    }
}