//
//  ThreadCell.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-23.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import UIKit
import FirebaseAuth

class PostCell: UITableViewCell {

    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    //@IBOutlet weak var numCommentsLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    
    var voteStatus: VoteStatus!
    var uid: String!
    var post: Post!
    var type: String = "replies"
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func configureCell(post: Post, type: String, extra: AnyObject){
        self.post = post
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            self.uid = uid
            print(post.text)
            guard let opText = post.text else { return }
            guard let time = post.time else { return }
            guard let points = post.points else { return }
        
            voteStatus = post.findUserVoteStatus(uid)
        
            textView.text = opText
            self.type = type
//            if type == "threads" {
//                if let thread = extra as? Thread {
//                    numCommentsLabel.text = "\(thread.numReplies) replies"
//                }
//            } else {
//                numCommentsLabel.text = ""
//            }
            pointsLabel.text = "\(points)"
            
            timeLabel.text = "\(getPostTime(time).0)\(getPostTime(time).1)"
            
            if voteStatus == VoteStatus.UpVote {
                displayUpVote()
            } else if voteStatus == VoteStatus.DownVote {
                displayDownVote()
            } else {
                displayNoVote()
            }
        }
    }
    
    func displayUpVote(){
        pointsLabel.textColor = UIColor(red: 60.0/255.0, green: 178.0/255.0, blue: 226.0/255.0, alpha: 1.0)
        upButton.setImage(UIImage(named:"up_colored"), forState: .Normal)
        downButton.setImage(UIImage(named:"down"), forState: .Normal)
    }
    
    func displayDownVote(){
        pointsLabel.textColor = UIColor(red: 60.0/255.0, green: 178.0/255.0, blue: 226.0/255.0, alpha: 1.0)
        upButton.setImage(UIImage(named:"up"), forState: .Normal)
        downButton.setImage(UIImage(named:"down_colored"), forState: .Normal)
    }
    
    func displayNoVote(){
        pointsLabel.textColor = UIColor.lightGrayColor()
        upButton.setImage(UIImage(named:"up"), forState: .Normal)
        downButton.setImage(UIImage(named:"down"), forState: .Normal)
    }
    
    func downloadThreadAndConfigure(threadKey: String, completion: (Thread)->()) {
        let thread = Thread(key: threadKey)
        thread.downloadThread(){ thread in
            self.configureCell(thread.originalPost, type: "threads", extra: thread)
            completion(thread)
        }
    }
    
    func downloadPostAndConfigure(postKey: String, completion: (Post) ->()) {
        let post = Post(key: postKey)
        post.downloadPost(){ post in
            self.configureCell(post, type: "replies", extra: [])
            completion(post)
        }
    }
    
    @IBAction func onUpButtonTapped(sender: UIButton) {
        bounceView(sender, amount: 1.5)
        guard let _ = voteStatus else { return }
        if voteStatus == VoteStatus.UpVote {
            voteStatus = VoteStatus.NoVote
            displayNoVote()
            vote(uid, type: type, key: post.key, voteType: "NoVote")
            post.upVotes[uid] = nil
        } else {
            voteStatus = VoteStatus.UpVote
            displayUpVote()
            vote(uid, type: type, key: post.key, voteType: "UpVote")
            post.upVotes[uid] = true
            post.downVotes[uid] = nil
        }
        pointsLabel.text = "\(post.points)"
    }
    
    @IBAction func onDownButtonTapped(sender: UIButton) {
        bounceView(sender, amount: 1.5)
        guard let _ = voteStatus else { return }
        if voteStatus == VoteStatus.DownVote {
            voteStatus = VoteStatus.NoVote
            displayNoVote()
            vote(uid, type: type, key: post.key, voteType: "NoVote")
            post.downVotes[uid] = nil
        } else {
            voteStatus = VoteStatus.DownVote
            displayDownVote()
            vote(uid, type: type, key: post.key, voteType: "DownVote")
            post.downVotes[uid] = true
            post.upVotes[uid] = nil
        }
        pointsLabel.text = "\(post.points)"
    }

}
