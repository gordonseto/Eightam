//
//  ThreadVC.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-23.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import UIKit
import SloppySwiper
import QuartzCore
import MBAutoGrowingTextView
import FirebaseAuth
import FirebaseDatabase

class ThreadVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var opTextView: UITextView!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var numCommentsLabel: UILabel!
    @IBOutlet weak var timeLabel: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var replyInput: MBAutoGrowingTextView!
    
    var refreshControl: UIRefreshControl!
    var noRepliesLabel: UILabel!
    
    var thread: Thread!
    
    var swiper: SloppySwiper!
    
    var uid: String!
    
    var replyKeys: [String] = []
    var replies: [Post] = []
    
    var voteStatus: VoteStatus!
    
    var type: String = "threads"
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        
        if let navigationcontroller = self.navigationController {
            swiper = SloppySwiper(navigationController: navigationcontroller)
            navigationcontroller.delegate = swiper
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("refreshView:"), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = UIColor.lightGrayColor()
        self.tableView.addSubview(refreshControl)
        self.tableView.scrollEnabled = true
        self.tableView.alwaysBounceVertical = true
        self.tableView.delaysContentTouches = false
        self.tableView.tableFooterView = UIView(frame: CGRectMake(0, 0, self.tableView.frame.size.width, 1))
        tableView.allowsSelection = true
        
        noRepliesLabel = UILabel(frame: CGRectMake(0, 0, 220, 120))
        
        replyInput.delegate = self
        replyInput.layer.cornerRadius = 4.0
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            self.uid = uid
            getReplies()
        }
    }
    
    func initializeOPView(){
        self.opTextView.text = thread.originalPost.text
        self.pointsLabel.text = "\(thread.originalPost.points)"
        self.voteStatus = thread.originalPost.findUserVoteStatus(self.uid)
        
        if thread.numReplies == 1 {
            self.numCommentsLabel.text = "\(thread.numReplies) reply"
        } else {
            self.numCommentsLabel.text = "\(thread.numReplies) replies"
        }
        
        if self.voteStatus == VoteStatus.UpVote {
            self.displayUpVote()
        } else if self.voteStatus == VoteStatus.DownVote {
            self.displayDownVote()
        } else {
            self.displayNoVote()
        }
    }
    
    func getReplies(){
        thread.downloadThread(){ thread in
            
            self.initializeOPView()
            
            self.replies = []
            self.replyKeys = Array(thread.replyKeys.keys)
            self.replyKeys = self.replyKeys.sort({$0 < $1})

            var downloadedPosts = 0
            for key in self.replyKeys {
                let post = Post(key: key)
                post.downloadPost(){post in
                    downloadedPosts++
                    self.replies.append(post)
                    if downloadedPosts == self.replyKeys.count {
                        self.doneGettingPosts()
                    }
                }
            }
            if self.replyKeys.count == 0 {
                self.doneGettingPosts()
            }
            
        }
    }
    
    func doneGettingPosts(){
        replies = replies.sort({$0.key < $1.key})
        self.refreshControl.endRefreshing()
        self.tableView.reloadData()
        if self.replies.count == 0 {
            displayBackgroundMessage("No Replies", label: noRepliesLabel, viewToAdd: tableView, height: 40, textSize: 17)
        } else {
            removeBackgroundMessage(noRepliesLabel)
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ReplyCell", forIndexPath: indexPath) as! PostCell
        let reply = replies[indexPath.row]
        cell.configureCell(reply, type: "replies", extra: [])
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.textColor = UIColor.blackColor()
        if textView.text == "Reply..." {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.lightGrayColor()
            textView.text = "Reply..."
        } else {
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let maxtext: Int = MAX_TEXT
        //If the text is larger than the maxtext, the return is false
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return textView.text.characters.count + (text.characters.count - range.length) <= maxtext
    }

    @IBAction func onSendButtonPressed(sender: AnyObject) {
        if let uid = uid {
            sendButton.userInteractionEnabled = false
            let post = Post(uid: uid, text: replyInput.text)
            post.post(thread.key){ post in
                self.replyInput.textColor = UIColor.lightGrayColor()
                self.replyInput.text = "Reply..."
                self.sendButton.userInteractionEnabled = true
                self.replies.append(post)
                self.tableView.reloadData()
                self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.replies.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
                removeBackgroundMessage(self.noRepliesLabel)
                if self.replies.count == 1 {
                    self.numCommentsLabel.text = "\(self.replies.count) reply"
                } else {
                    self.numCommentsLabel.text = "\(self.replies.count) replies"
                }
            }
        }
    }

    @IBAction func onBackButtonPressed(sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    
    func refreshView(sender: AnyObject){
        getReplies()
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
    
    @IBAction func onUpButtonTapped(sender: UIButton) {
        bounceView(sender, amount: 1.5)
        guard let _ = voteStatus else { return }
        guard let _ = thread.originalPost.key else { return }
        if voteStatus == VoteStatus.UpVote {
            voteStatus = VoteStatus.NoVote
            displayNoVote()
            vote(uid, type: type, key: thread.originalPost.key, voteType: "NoVote")
            thread.originalPost.upVotes[uid] = nil
        } else {
            voteStatus = VoteStatus.UpVote
            displayUpVote()
            vote(uid, type: type, key: thread.originalPost.key, voteType: "UpVote")
            thread.originalPost.upVotes[uid] = true
            thread.originalPost.downVotes[uid] = nil
        }
        pointsLabel.text = "\(thread.originalPost.points)"
    }
    
    @IBAction func onDownButtonTapped(sender: UIButton) {
        bounceView(sender, amount: 1.5)
        guard let _ = voteStatus else { return }
        guard let _ = thread.originalPost.key else { return }
        if voteStatus == VoteStatus.DownVote {
            voteStatus = VoteStatus.NoVote
            displayNoVote()
            vote(uid, type: type, key: thread.originalPost.key, voteType: "NoVote")
            thread.originalPost.downVotes[uid] = nil
        } else {
            voteStatus = VoteStatus.DownVote
            displayDownVote()
            vote(uid, type: type, key: thread.originalPost.key, voteType: "DownVote")
            thread.originalPost.downVotes[uid] = true
            thread.originalPost.upVotes[uid] = nil
        }
        pointsLabel.text = "\(thread.originalPost.points)"
    }
}
