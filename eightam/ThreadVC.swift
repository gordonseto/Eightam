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
    
    var thread: Thread!
    
    var swiper: SloppySwiper!
    
    var uid: String!
    
    var replyKeys: [String] = []
    var replies: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        
        if let navigationcontroller = self.navigationController {
            swiper = SloppySwiper(navigationController: navigationcontroller)
            navigationcontroller.delegate = swiper
        }
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("refreshView:"), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = UIColor.lightGrayColor()
        self.tableView.addSubview(refreshControl)
        self.tableView.scrollEnabled = true
        self.tableView.alwaysBounceVertical = true
        self.tableView.delaysContentTouches = false
        tableView.allowsSelection = true
        
        replyInput.delegate = self
        replyInput.layer.cornerRadius = 4.0
        
        opTextView.text = thread.originalPost.text
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            self.uid = uid
            getReplies()
        }
    }
    
    func getReplies(){
        thread.downloadThread(){ thread in
            self.replies = []
            self.replyKeys = Array(thread.replyKeys.keys)
            self.replyKeys = self.replyKeys.sort({$0 < $1})
            print(self.replyKeys)
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
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
        let key = replyKeys[indexPath.row]
        if let index = replies.indexOf({$0.key == key}) {
            cell.configureCell(replies[index], type: "replies", extra: [])
        } else {
            cell.downloadPostAndConfigure(key) {post in
                self.replies.append(post)
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replyKeys.count
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
                self.getReplies()
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
}
