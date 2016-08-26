//
//  ExploreVC.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-25.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import CoreLocation

class ExploreVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var basecampLabel: UILabel!
    @IBOutlet weak var basecampView: CardView!
    
    var refreshControl: UIRefreshControl!
    
    let NO_BASECAMP_TEXT = "Tap here to set your basecamp. Your basecamp can only be set once and allows you to post and vote even when you are away from it."
    
    var uid: String!
    
    var firebase: FIRDatabaseReference!
    
    var basecamp: CLLocation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = true
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("refreshView:"), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = UIColor.whiteColor()
        self.tableView.addSubview(refreshControl)
        self.tableView.scrollEnabled = true
        self.tableView.alwaysBounceVertical = true
        self.tableView.delaysContentTouches = false
        tableView.allowsSelection = true
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            self.uid = uid
            
            checkForBasecamp()
        }
    }
    
    func checkForBasecamp(){
        firebase = FIRDatabase.database().reference()
        firebase.child("basecamps").child(uid).observeSingleEventOfType(.Value, withBlock: {snapshot in
            self.basecampLabel.text = self.NO_BASECAMP_TEXT
            self.basecamp = nil
            if let latitude = snapshot.value!["latitude"] as? Double {
                if let longitude = snapshot.value!["longitude"] as? Double {
                    if let basecampName = snapshot.value!["name"] as? String {
                        self.setBasecamp(latitude, longitude: longitude, name: basecampName)
                    }
                }
            }
        })
    }
    
    func setBasecamp(latitude: CLLocationDegrees, longitude: CLLocationDegrees, name: String) {
        basecamp = CLLocation(latitude: latitude, longitude: longitude)
        basecampLabel.font = UIFont(name: "Helvetica-Neue", size: 15.0)
        basecampLabel.textColor = DARK_GREY_TEXT_COLOR
        basecampLabel.text = name
    }

    @IBAction func onBasecampTapped(sender: AnyObject) {
        if let _ = uid {
            if let _ = basecamp {
                performSegueWithIdentifier("homeVCFromBasecamp", sender: nil)
            } else {
                performSegueWithIdentifier("mapVCFromBasecamp", sender: nil)
            }
        }
    }
    
    @IBAction func onPeekButtonTapped(sender: AnyObject) {
        performSegueWithIdentifier("mapVCFromPeekButton", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mapVCFromBasecamp" {
            if let destinationVC = segue.destinationViewController as? MapVC {
                destinationVC.isPeekLocation = true
                destinationVC.isBasecampOption = true
            }
        } else if segue.identifier == "homeVCFromBasecamp" {
            if let destinationVC = segue.destinationViewController as? HomeVC {
                destinationVC.isBasecamp = true
                destinationVC.currentLocation = basecamp
            }
        } else if segue.identifier == "mapVCFromPeekButton" {
            if let destinationVC = segue.destinationViewController as? MapVC {
                destinationVC.isBasecampOption = false
                destinationVC.isPeekLocation = true
            }
        }
    }
    
    func refreshView(sender: AnyObject){
        checkForBasecamp()
        refreshControl.endRefreshing()
    }
    
}
