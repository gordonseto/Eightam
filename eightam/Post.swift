//
//  Post.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-24.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import Foundation
import FirebaseDatabase

class Post {
    private var _key: String!
    private var _authorUid: String!
    private var _text: String!
    private var _time: NSTimeInterval!
    private var _points: Int!
    private var _upVotes: [String: Bool]!
    private var _downVotes: [String: Bool]!
    
    var key: String! {
        return _key
    }
    
    var authorUid: String! {
        return _authorUid
    }
    
    var text: String! {
        return _text
    }
    
    var time: NSTimeInterval! {
        return _time
    }
    
    var points: Int! {
        return _upVotes.count - _downVotes.count
    }
    
    var upVotes: [String: Bool]! {
        get {return _upVotes}
        set { _upVotes = newValue}
    }
    
    var downVotes: [String: Bool]! {
        get {return _downVotes}
        set {_downVotes = newValue}
    }
    
    var numVoters: Int! {
        return _upVotes.count + _downVotes.count
    }
    
    var notificationMilestone: Int = 0
    
    var firebase: FIRDatabaseReference!
    
    init(key: String) {
        _key = key
    }
    
    init(uid: String, text: String){
        _authorUid = uid
        _text = text
        _time = NSDate().timeIntervalSince1970
        upVotes = [:]
        downVotes = [:]
    }
    
    init(key: String, uid: String, text: String, upVotes: [String:Bool], downVotes: [String:Bool], time: NSTimeInterval){
        _key = key
        _authorUid = uid
        _text = text
        _upVotes = upVotes
        _downVotes = downVotes
        _time = time
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
    
    func post(threadId: String, completion: (Post) -> ()) {
        guard let authorUid = _authorUid else { return }
        guard let text = text else { return }
        guard let time = _time else { return }
        
        let post = ["authorUid": authorUid, "text": text, "time": time]
        
        firebase = FIRDatabase.database().reference()
        
        _key = firebase.child("threads").child(threadId).child("replies").childByAutoId().key
        firebase.child("replies").child(_key).setValue(post)
        firebase.child("users").child(authorUid).child("replies").child(_key).setValue(time)
        firebase.child("threads").child(threadId).child("replies").child(_key).setValue(true)
        
        completion(self)
    }
    
    func downloadPost(completion: (Post) ->()){
        guard let key = _key else { return }
        
        firebase = FIRDatabase.database().reference()
        firebase.child("replies").child(_key).observeSingleEventOfType(.Value, withBlock: {snapshot in
            self._authorUid = snapshot.value!["authorUid"] as? String ?? ""
            self._text = snapshot.value!["text"] as? String ?? ""
            self._time = snapshot.value!["time"] as? NSTimeInterval ?? NSDate().timeIntervalSince1970
            self._upVotes = snapshot.value!["upVotes"] as? [String: Bool] ?? [:]
            self._downVotes = snapshot.value!["downVotes"] as? [String: Bool] ?? [:]
            
            print("downloaded \(self.text)")
            completion(self)
        })
    }

}