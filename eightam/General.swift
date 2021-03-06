//
//  General.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-23.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import Foundation
import UIKit
import FirebaseDatabase

func generateToolbar(viewController: UIViewController) -> UIToolbar {
    let numberToolbar = UIToolbar(frame: CGRectMake(0, 0, viewController.view.frame.size.width, 50))
    numberToolbar.barStyle = UIBarStyle.Default
    
    let sendButton = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Plain, target: viewController, action: #selector(HomeVC.onKeyboardSendTapped(_:)))
    sendButton.tintColor = UIColor.blackColor()
    sendButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 16.0)!], forState: UIControlState.Normal)
    
    numberToolbar.items = [
        UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
        sendButton]
    numberToolbar.sizeToFit()
    
    return numberToolbar
}

func bounceView(view: UIView, amount: CGFloat){
    UIView.animateWithDuration(0.1, delay: 0.0, options: [], animations: {
        view.transform = CGAffineTransformMakeScale(amount, amount)
        }, completion: {completed in
            UIView.animateWithDuration(0.1, delay: 0.0, options: [], animations: {
                view.transform = CGAffineTransformMakeScale(1.0, 1.0)
                }, completion: {completed in })
    })
}

func vote(uid: String, type: String, post: Post, voteType: String, oldVoteType: VoteStatus){
    let firebase = FIRDatabase.database().reference()

    if post.numVoters % 5 == 0 && voteType != "NoVote" && post.numVoters > post.notificationMilestone && uid != post.authorUid {
        post.notificationMilestone = post.numVoters
        NotificationsManager.sharedInstance.createVoteNotification(post, type: type)
    }
    if voteType == "NoVote" {
        firebase.child(type).child(post.key).child("upVotes").child(uid).setValue(nil)
        firebase.child(type).child(post.key).child("downVotes").child(uid).setValue(nil)
    } else if voteType == "UpVote" {
        firebase.child(type).child(post.key).child("upVotes").child(uid).setValue(true)
        firebase.child(type).child(post.key).child("downVotes").child(uid).setValue(nil)
    } else {
        firebase.child(type).child(post.key).child("upVotes").child(uid).setValue(nil)
        firebase.child(type).child(post.key).child("downVotes").child(uid).setValue(true)
    }
    
    if type == "threads" {
        firebase.child("geolocations").child(post.threadKey).runTransactionBlock({ (currentData: FIRMutableData) -> FIRTransactionResult in
            if var thread = currentData.value as? [String: AnyObject] {
                var points = thread["points"] as? Int ?? 0
                print(points)
                if voteType == "UpVote" {
                    if oldVoteType == VoteStatus.NoVote {
                        points += 1
                    } else {
                        points += 2
                    }
                } else if voteType == "DownVote" {
                    if oldVoteType == VoteStatus.NoVote {
                        points -= 1
                    } else {
                        points -= 2
                    }
                } else {
                    if oldVoteType == VoteStatus.UpVote {
                        points -= 1
                    } else {
                        points += 1
                    }
                }
                print(points)
                thread["points"] = points
                currentData.value = thread
                return FIRTransactionResult.successWithValue(currentData)
            }
            return FIRTransactionResult.successWithValue(currentData)
            }, andCompletionBlock: { (error, committed, snapshot) in
                if error != nil {
                    print("error in transaction")
                }
        })
    }
}

func getPostTime(time: NSTimeInterval) -> (value: String, unit: String) {
    let currentTime = NSDate().timeIntervalSince1970
    var timeDifference = currentTime - time
    if timeDifference < 60 { // seconds
        return ("\(Int(timeDifference))", "s")
    } else {
        timeDifference /= 60.0
        if timeDifference < 60 { //minutes
            return ("\(Int(timeDifference))", "m")
        } else {
            timeDifference /= 60.0
            if timeDifference < 24 { //hours
                return ("\(Int(timeDifference))", "h")
            } else {
                timeDifference /= 24.0
                if timeDifference < 7 { //days
                    return ("\(Int(timeDifference))", "d")
                } else {
                    timeDifference /= 7.0
                    if timeDifference < 52.0 { //weeks
                        return ("\(Int(timeDifference))", "w")
                    } else {
                        return ("\(Int(timeDifference))", "y") //years
                    }
                }
            }
        }
    }
}

func displayBackgroundMessage(message: String, label: UILabel, viewToAdd: UIView, height: CGFloat, textSize: CGFloat) {
    label.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2, UIScreen.mainScreen().bounds.size.height/2 - height)
    label.text = message
    label.textAlignment = .Center
    label.font = UIFont(name: "HelveticaNeue-Bold", size: textSize)
    label.textColor = UIColor.lightGrayColor()
    viewToAdd.addSubview(label)
}

func removeBackgroundMessage(label: UILabel!){
    if let label = label {
        label.removeFromSuperview()
    }
}

func startLoadingAnimation(activityIndicator: UIActivityIndicatorView, loadingLabel: UILabel, viewToAdd: UIView){
    activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    activityIndicator.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2 - 32, UIScreen.mainScreen().bounds.size.height/2 - 90)
    activityIndicator.startAnimating()
    viewToAdd.addSubview(activityIndicator)
    
    loadingLabel.center = CGPointMake(UIScreen.mainScreen().bounds.size.width/2 + 32, UIScreen.mainScreen().bounds.size.height/2 - 90)
    loadingLabel.text = "Loading..."
    loadingLabel.textColor = UIColor.grayColor()
    viewToAdd.addSubview(loadingLabel)
}

func stopLoadingAnimation(activityIndicator: UIActivityIndicatorView, loadingLabel: UILabel){
    activityIndicator.removeFromSuperview()
    loadingLabel.removeFromSuperview()
}

