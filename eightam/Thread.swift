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

enum VoteStatus {
    case UpVote, DownVote, NoVote
}

class Thread {
    
    private var _key: String!
    private var _authorUid: String!
    private var _opText: String!
    private var _time: NSTimeInterval!
    private var _geolocation: CLLocation!
    private var _points: Int!
    private var _numComments: Int!
    private var _upVotes: [String: Bool]!
    private var _downVotes: [String: Bool]!
    
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
        return _upVotes.count - _downVotes.count
    }
    
    var numComments: Int! {
        return _numComments
    }
    
    var upVotes: [String: Bool]! {
        get {return _upVotes}
        set { _upVotes = newValue}
    }
    
    var downVotes: [String: Bool]! {
        get {return _downVotes}
        set {_downVotes = newValue}
    }
    
    var firebase: FIRDatabaseReference!
    
    init(authorUid: String, text: String, geolocation: CLLocation!) {
        _opText = text
        _geolocation = geolocation
        _authorUid = authorUid
        _time = NSDate().timeIntervalSince1970
        _upVotes = [:]
        _downVotes = [:]
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
            self._upVotes = snapshot.value!["upVotes"] as? [String: Bool] ?? [:]
            self._downVotes = snapshot.value!["downVotes"] as? [String: Bool] ?? [:]
            self._numComments = snapshot.value!["numComments"] as? Int ?? 0
            
            print("downloaded \(self.opText)")
            completion(self)
        })
    }
    
    func findUserVoteStatus(uid: String) -> VoteStatus {
        guard let upVotes = _upVotes else { return VoteStatus.NoVote }
        guard let downVotes = _downVotes else { return VoteStatus.NoVote }
        
        if upVotes[uid] != nil {
            return VoteStatus.UpVote
        } else if downVotes[uid] != nil {
            return VoteStatus.DownVote
        } else {
            return VoteStatus.NoVote
        }
        
    }
}