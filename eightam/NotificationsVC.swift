//
//  NotificationsVC.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-27.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SloppySwiper

class NotificationsVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    var noNotificationsLabel: UILabel!
    
    var swiper: SloppySwiper!
    var refreshControl: UIRefreshControl!
    
    var firebase: FIRDatabaseReference!
    
    var notifications: [Notification] = []
    
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBarHidden = true
        
        if let navigationcontroller = self.navigationController {
            swiper = SloppySwiper(navigationController: navigationcontroller)
            navigationcontroller.delegate = swiper
        }
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("refreshView:"), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = UIColor.lightGrayColor()
        self.tableView.addSubview(refreshControl)
        self.tableView.scrollEnabled = true
        self.tableView.alwaysBounceVertical = true
        self.tableView.delaysContentTouches = false
        tableView.allowsSelection = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        noNotificationsLabel = UILabel(frame: CGRectMake(0, 0, 220, 120))
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            self.uid = uid
            getNotifications()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
    
    func getNotifications(){
        firebase =  FIRDatabase.database().reference()
        firebase.child("notifications").child(uid).queryOrderedByKey().observeSingleEventOfType(.Value, withBlock: {snapshot in
            print(snapshot)
            self.notifications = []
            for child in snapshot.children {
                let threadKey = child.value!["threadKey"] as? String ?? ""
                let message = child.value!["message"] as? String ?? ""
                let seen = child.value!["seen"] as? Bool ?? false
                let time = child.value!["time"] as? NSTimeInterval ?? 0
                print(message)
                let notification = Notification(key: child.key, uid: self.uid, threadKey: threadKey, message: message, seen: seen, time: time)
                self.notifications.append(notification)
            }
            print(self.notifications)
            self.doneGettingNotifications()
        })
    }
    
    func doneGettingNotifications(){
        notifications = notifications.reverse()
        refreshControl.endRefreshing()
        tableView.reloadData()
        if notifications.count == 0 {
            displayBackgroundMessage("You have no notifications.", label: noNotificationsLabel, viewToAdd: tableView, height: 120, textSize: 17)
        } else {
            removeBackgroundMessage(noNotificationsLabel)
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NotificationCell", forIndexPath: indexPath) as! NotificationCell
        let notification = notifications[indexPath.row]
        cell.configureCell(notification)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let notification = notifications[indexPath.row]
        let thread = Thread(key: notification.threadKey)
        performSegueWithIdentifier("threadVCFromNotifications", sender: thread)
        notification.setAsSeen()
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func refreshView(sender: AnyObject){
        if let _ = uid {
            getNotifications()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "threadVCFromNotifications" {
            if let destinationVC = segue.destinationViewController as? ThreadVC {
                destinationVC.thread = sender as? Thread
            }
        }
    }

}
