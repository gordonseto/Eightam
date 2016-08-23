//
//  Thread.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-23.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import Foundation
import CoreLocation
import BoltsSwift
import FirebaseAuth
import FirebaseDatabase
import GeoFire

class Thread {
    
    private var _key: String!
    private var _authorUid: String!
    private var _opText: String!
    private var _time: NSTimeInterval!
    private var _geolocation: CLLocation!
    private var _points: Int!
    
    var key: String! {
        return _key
    }
    
    var authorUid: String! {
        return _authorUid
    }
    
    var opText: String! {
        return _opText
    }
    
    var time: NSTimeInterval! {
        return _time
    }
    
    var geolocation: CLLocation! {
        return _geolocation
    }
    
    var points: Int! {
        return _points
    }
    
    var firebase: FIRDatabaseReference!
    
    init(authorUid: String, text: String, geolocation: CLLocation!) {
        _opText = text
        _geolocation = geolocation
        _authorUid = authorUid
    }
    
    init(key: String!){
        _key = key
    }
    
    func newThread(){
        _time = NSDate().timeIntervalSince1970
        _points = 0
    }
    
    func postThread() -> Task<Thread> {
        
        let taskCompletionSource = TaskCompletionSource<Thread>()
        
        guard let authorUid = _authorUid else { return taskCompletionSource.task}
        guard let opText = _opText else { return taskCompletionSource.task}
        guard let time = _time else { return taskCompletionSource.task}
        guard let geolocation = _geolocation else { return taskCompletionSource.task}
        guard let points = _points else { return taskCompletionSource.task}
        
        let thread = ["authorUid": authorUid, "opText": opText, "time": time, "points": points]
        
        firebase = FIRDatabase.database().reference()
        let geofire = GeoFire(firebaseRef: firebase.child("geolocations"))
        
        let key = firebase.child("threads").childByAutoId().key
        firebase.child("threads").child(key).setValue(thread)
        firebase.child("users").child(authorUid).child("threads").child(key).setValue(time)
        
        geofire.setLocation(geolocation, forKey: key, withCompletionBlock: { (error) in
            if error != nil {
                taskCompletionSource.setError(error)
            } else {
                taskCompletionSource.setResult(self)
            }
        })
        
        return taskCompletionSource.task
        
    }
}