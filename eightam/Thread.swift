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
    private var _time: NSTimeInterval!
    private var _geolocation: CLLocation!
    private var _replyKeys: [String: Bool]!
    var replies: [Post] = []
    
    var originalPost: Post!
    
    var key: String! {
        return _key
    }
    
    var authorUid: String! {
        return _authorUid
    }
    
    var time: NSTimeInterval! {
        return _time
    }
    
    var geolocation: CLLocation! {
        return _geolocation
    }
    
    var replyKeys: [String: Bool] {
        return _replyKeys
    }
    
    var numReplies: Int {
        return replyKeys.count
    }
    
    var firebase: FIRDatabaseReference!
    
    init(authorUid: String, text: String, geolocation: CLLocation!) {
        _geolocation = geolocation
        _authorUid = authorUid
        _time = NSDate().timeIntervalSince1970
        originalPost = Post(uid: authorUid, threadKey: "", text: text)
    }
    
    init(key: String!){
        _key = key
    }
    
    func postThread(completion: (Thread)->()) {
        
        guard let authorUid = _authorUid else { return }
        guard let opText = originalPost.text else { return }
        guard let time = _time else { return }
        guard let geolocation = _geolocation else { return }

        let thread = ["authorUid": authorUid, "opText": opText, "time": time]
        
        firebase = FIRDatabase.database().reference()
        let geofire = GeoFire(firebaseRef: firebase.child("geolocations"))
        
        _key = firebase.child("threads").childByAutoId().key
        firebase.child("threads").child(_key).setValue(thread)
        firebase.child("threadInfos").child(authorUid).child(_key).setValue(time)
        
        geofire.setLocation(geolocation, forKey: _key, withCompletionBlock: { (error) in
            if error != nil {
                print(error)
                return
            } else {
                completion(self)
            }
        })
        
        originalPost = Post(uid: authorUid, threadKey: _key, text: opText)
    }
    
    func downloadThread(completion: (Thread) ->()) {
        guard let key = _key else { return }
        
        firebase = FIRDatabase.database().reference()
        firebase.child("threads").child(_key).observeSingleEventOfType(.Value, withBlock: {snapshot in
            self._authorUid = snapshot.value!["authorUid"] as? String ?? ""
            let text = snapshot.value!["opText"] as? String ?? ""
            self._time = snapshot.value!["time"] as? NSTimeInterval ?? NSDate().timeIntervalSince1970
            let upVotes = snapshot.value!["upVotes"] as? [String: Bool] ?? [:]
            let downVotes = snapshot.value!["downVotes"] as? [String: Bool] ?? [:]
            self._replyKeys = snapshot.value!["replies"] as? [String: Bool] ?? [:]
            
            self.originalPost = Post(key: key, uid: self._authorUid, threadKey: key, text: text, upVotes: upVotes, downVotes: downVotes, time: self._time)
            
            print("downloaded \(text)")
            completion(self)
        })
    }

}