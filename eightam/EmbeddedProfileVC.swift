//
//  EmbeddedProfileVC.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-29.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import FirebaseAuth
import FirebaseDatabase

class EmbeddedProfileVC: UIViewController, IndicatorInfoProvider, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    var type: String!
    
    var uid: String!
    
    var firebase: FIRDatabaseReference!
    
    var keys: [String] = []
    var threads: [Thread] = []
    var replies: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            self.uid = uid
            downloadContent()
        }
    }
    
    func downloadContent(){
        firebase = FIRDatabase.database().reference()
        var queryType = ""
        if type == "My Threads" {
            queryType = "threadInfos"
        } else {
            queryType = "replyInfos"
        }
        firebase.child(queryType).child(uid).observeSingleEventOfType(.Value, withBlock: {snapshot in
            print(snapshot)
            self.keys = []
            self.threads = []
            self.replies = []
            for child in snapshot.children {
                self.keys.append(child.key)
            }
            self.doneRetrievingKeys()
        })
    }
    
    func doneRetrievingKeys(){
        print(self.keys)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MyPostCell", forIndexPath: indexPath) as! MyPostCell
        let key = keys[indexPath.row]
        if type == "My Threads" {
            if let index = threads.indexOf({$0.key == key}) {
                cell.configureCell(threads[index].originalPost)
            } else {
                cell.downloadAndConfigureCell(key, type: type){ thread in
                    if let thread = thread as? Thread {
                        self.threads.append(thread)
                    }
                }
            }
        } else {
            if let index = replies.indexOf({$0.key == key}) {
                cell.configureCell(replies[index])
            } else {
                cell.downloadAndConfigureCell(key, type: type) { post in
                    if let post = post as? Post {
                        self.replies.append(post)
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return keys.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: type)
    }
}
