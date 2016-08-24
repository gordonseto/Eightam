//
//  ThreadCell.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-23.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import UIKit
import FirebaseAuth

class ThreadCell: UITableViewCell {

    
    @IBOutlet weak var opTextView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var numCommentsLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    
    var voteStatus: VoteStatus!
    var uid: String!
    var thread: Thread!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func configureCell(thread: Thread){
        self.thread = thread
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            self.uid = uid
            print(thread.opText)
            guard let opText = thread.opText else { return }
            guard let time = thread.time else { return }
            guard let numComments = thread.numComments else { return }
            guard let points = thread.points else { return }
        
            voteStatus = thread.findUserVoteStatus(uid)
        
            opTextView.text = opText
            numCommentsLabel.text = "\(numComments) replies"
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
            self.configureCell(thread)
            completion(thread)
        }
    }
    
    @IBAction func onUpButtonTapped(sender: UIButton) {
        bounceView(sender)
        guard let _ = voteStatus else { return }
        if voteStatus == VoteStatus.UpVote {
            voteStatus = VoteStatus.NoVote
            displayNoVote()
            vote(uid, type: "threads", key: thread.key, voteType: "NoVote")
            thread.upVotes[uid] = nil
        } else {
            voteStatus = VoteStatus.UpVote
            displayUpVote()
            vote(uid, type: "threads", key: thread.key, voteType: "UpVote")
            thread.upVotes[uid] = true
            thread.downVotes[uid] = nil
        }
        pointsLabel.text = "\(thread.points)"
    }
    
    @IBAction func onDownButtonTapped(sender: UIButton) {
        bounceView(sender)
        guard let _ = voteStatus else { return }
        if voteStatus == VoteStatus.DownVote {
            voteStatus = VoteStatus.NoVote
            displayNoVote()
            vote(uid, type: "threads", key: thread.key, voteType: "NoVote")
            thread.downVotes[uid] = nil
        } else {
            voteStatus = VoteStatus.DownVote
            displayDownVote()
            vote(uid, type: "threads", key: thread.key, voteType: "DownVote")
            thread.downVotes[uid] = true
            thread.upVotes[uid] = nil
        }
        pointsLabel.text = "\(thread.points)"
    }

}
