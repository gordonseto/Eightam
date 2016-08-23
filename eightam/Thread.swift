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
    private var _numComments: Int!
    
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
    
    var numComments: Int! {
        return _numComments
    }
    
    var firebase: FIRDatabaseReference!
    
    init(authorUid: String, text: String, geolocation: CLLocation!) {
        _opText = text
        _geolocation = geolocation
        _authorUid = authorUid
        _time = NSDate().timeIntervalSince1970
        _points = 0
        _numComments = 0
    }
    
    init(key: String!){
        _key = key
    }
    
    func postThread(completion: (Thread)->()) {
        
        guard let authorUid = _authorUid else { return }
        guard let opText = _opText else { return }
        guard let time = _time else { return }
        guard let geolocation = _geolocation else { return }

        let thread = ["authorUid": authorUid, "opText": opText, "time": time]
        
        firebase = FIRDatabase.database().reference()
        let geofire = GeoFire(firebaseRef: firebase.child("geolocations"))
        
        let key = firebase.child("threads").childByAutoId().key
        firebase.child("threads").child(key).setValue(thread)
        firebase.child("users").child(authorUid).child("threads").child(key).setValue(time)
        
        geofire.setLocation(geolocation, forKey: key, withCompletionBlock: { (error) in
            if error != nil {
                print(error)
                return
            } else {
                completion(self)
            }
        })
    }
    
    func downloadThread(completion: (Thread) ->()) {
        guard let key = _key else { return }
        
        firebase = FIRDatabase.database().reference()
        firebase.child("threads").child(_key).observeSingleEventOfType(.Value, withBlock: {snapshot in
            self._authorUid = snapshot.value!["authorUid"] as? String ?? ""
            self._opText = snapshot.value!["opText"] as? String ?? ""
            self._time = snapshot.value!["time"] as? NSTimeInterval ?? NSDate().timeIntervalSince1970
            self._points = snapshot.value!["points"] as? Int ?? 0
            self._numComments = snapshot.value!["numComments"] as? Int ?? 0
            
            print("downloaded \(self.opText)")
            completion(self)
        })
    }
}