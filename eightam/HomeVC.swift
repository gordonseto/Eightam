//
//  ViewController.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-23.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import GeoFire
import BoltsSwift

class HomeVC: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet weak var newPostTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var tableView: UITableView!
    
    var refreshControl: UIRefreshControl!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var threads: [Thread] = []
    var threadKeys: [String] = []
    
    var firebase: FIRDatabaseReference!
    
    var hasLoadedThreads: Bool = false
    
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        self.navigationController?.navigationBarHidden = true
        
        newPostTextView.delegate = self
        
        newPostTextView.inputAccessoryView = generateToolbar(self)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: Selector("refreshView:"), forControlEvents: UIControlEvents.ValueChanged)
        refreshControl.tintColor = UIColor.whiteColor()
        self.tableView.addSubview(refreshControl)
        self.tableView.scrollEnabled = true
        self.tableView.alwaysBounceVertical = true
        self.tableView.delaysContentTouches = false
        tableView.allowsSelection = true
        
        locationManager.delegate = self
        
        firebase = FIRDatabase.database().reference()
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            self.uid = uid
            beginHomeVC()
        }
    }
    
    func beginHomeVC() {
        locationAuthStatus()
    }
    
    func queryThreads(){
        if let currentloc = currentLocation {
            if threads.count == 0 {
                
            }
            firebase.removeAllObservers()
            hasLoadedThreads = true
            
            let geofireRef = firebase.child("geolocations")
            let geofire = GeoFire(firebaseRef: geofireRef)
            
            var radius: Double
            if let rad = NSUserDefaults.standardUserDefaults().objectForKey("SEARCH_RADIUS") as? Double {
                radius = rad
            } else {
                radius = 30 //km
                NSUserDefaults.standardUserDefaults().setObject(radius, forKey: "SEARCH_RADIUS")
            }
            
            threads = []
            threadKeys = []
            
            let circleQuery = geofire.queryAtLocation(currentloc, withRadius: radius)
            circleQuery.observeEventType(.KeyEntered, withBlock: { (key: String!, location: CLLocation! ) in
                print("got \(key)")
                self.threadKeys.append(key)
            })
            
            circleQuery.observeReadyWithBlock({
                circleQuery.removeAllObservers()
                self.doneGettingKeys()
            })
            
        }
    }
    
    func doneGettingKeys(){
        print(threadKeys)
        threadKeys = threadKeys.sort({$0 > $1})
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    func postNewThread(){
        guard let uid = uid else { return }
        guard let currentLocation = currentLocation else { return }
        guard let text = newPostTextView.text where text != "" || text != "What's up?" else { return }
        
        newPostTextView.userInteractionEnabled = false
        let thread = Thread(authorUid: uid, text: text, geolocation: currentLocation)
        thread.postThread(){ thread in
            self.newPostTextView.textColor = UIColor.lightGrayColor()
            self.newPostTextView.text = "What's up?"
            self.newPostTextView.userInteractionEnabled = true
            self.characterCountLabel.text = "\(MAX_TEXT)"
            self.queryThreads()
        }
    }
    
    func onKeyboardSendTapped(sender: AnyObject){
        newPostTextView.resignFirstResponder()
        postNewThread()
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ThreadCell", forIndexPath: indexPath) as! PostCell
        let key = threadKeys[indexPath.row]
        if let index = threads.indexOf({$0.key == key}) {
            cell.configureCell(threads[index].originalPost, type: "threads", extra: threads[index])
        } else {
            cell.downloadThreadAndConfigure(key) {thread in
                self.threads.append(thread)
            }
        }
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return threadKeys.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let thread = threads[indexPath.row]
        performSegueWithIdentifier("threadVCFromHome", sender: thread)
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            //print(location)
            self.currentLocation = location
            if !hasLoadedThreads {
                queryThreads()
            }
        }
    }
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        textView.textColor = UIColor(red: 47.0/255.0, green: 47.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        if textView.text == "What's up?" {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.lightGrayColor()
            textView.text = "What's up?"
        } else {
            textView.textColor = UIColor(red: 47.0/255.0, green: 47.0/255.0, blue: 47.0/255.0, alpha: 1.0)
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        characterCountLabel.text = "\(MAX_TEXT - textView.text.characters.count)"
        bounceView(characterCountLabel, amount: 1.1)
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
    
    func refreshView(sender: AnyObject){
        queryThreads()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "threadVCFromHome" {
            if let destinationVC = segue.destinationViewController as? ThreadVC {
                destinationVC.thread = sender as? Thread
            }
        }
    }

}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
