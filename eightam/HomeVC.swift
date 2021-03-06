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
import SloppySwiper

class HomeVC: UIViewController, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, ThreadVCDelegate {

    @IBOutlet weak var newPostTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var newPostView: UIView!
    @IBOutlet weak var bannerButton: UIButton!
    
    var refreshControl: UIRefreshControl!
    var activityIndicator: UIActivityIndicatorView!
    var loadingLabel: UILabel!
    var noThreadsLabel: UILabel!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var threads: [Thread] = []
    var threadKeys: [String] = []
    
    var firebase: FIRDatabaseReference!
    
    var hasLoadedThreads: Bool = false
    
    var uid: String!
    
    var isPeekLocation: Bool = false
    var isBasecampOption: Bool = false
    var isBasecamp: Bool = false
    var peekLocationName: String!
    
    var swiper: SloppySwiper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tbc = self.tabBarController
        tbc?.tabBar.selectedImageTintColor = BLUE_COLOR
        
        hideKeyboardWhenTappedAround()
        
        self.navigationController?.navigationBarHidden = true
        
        if let navigationcontroller = self.navigationController {
            swiper = SloppySwiper(navigationController: navigationcontroller)
            navigationcontroller.delegate = swiper
        }
        activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        loadingLabel = UILabel(frame: CGRectMake(0, 0, 100, 30))
        noThreadsLabel = UILabel(frame: CGRectMake(0, 0, 220, 120))
        noThreadsLabel.numberOfLines = 2
        
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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.hidden = false
    }
    
    func beginHomeVC() {
        if !isPeekLocation {
            bannerButton.hidden = true
            newPostView.hidden = false
            backButton.hidden = true
            if isBasecamp {
                backButton.hidden = false
                queryThreads()
            } else {
                locationAuthStatus()
            }
        } else {
            if let _ = currentLocation {
                if isBasecampOption {
                    bannerButton.setTitle("Set As Basecamp", forState: .Normal)
                } else {
                    if let peekLocationName = peekLocationName {
                        bannerButton.setTitle("\(peekLocationName)", forState: .Normal)
                    }
                }
                bannerButton.hidden = false
                bannerButton.layer.shadowColor = DISABLED_GREY_COLOR.CGColor
                bannerButton.layer.shadowOffset = CGSizeMake(0, 1.0);
                bannerButton.layer.shadowOpacity = 1.0;
                bannerButton.layer.shadowRadius = 0.0;
                newPostView.hidden = true
                newPostView.bounds = CGRectMake(newPostView.bounds.minX, self.view.bounds.height, newPostView.bounds.width, 0)
                backButton.hidden = false
                queryThreads()
            }
        }
    }
    
    func queryThreads(){
        if let currentloc = currentLocation {
            if threads.count == 0 {
                //display loading message
                startLoadingAnimation(activityIndicator, loadingLabel: loadingLabel, viewToAdd: tableView)
                removeBackgroundMessage(noThreadsLabel)
            }
            firebase.removeAllObservers()
            hasLoadedThreads = true
            
            let geofireRef = firebase.child("geolocations")
            let geofire = GeoFire(firebaseRef: geofireRef)
            
            let radius: Double = SEARCH_RADIUS //km
            
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
        stopLoadingAnimation(self.activityIndicator, loadingLabel: self.loadingLabel)
        if threadKeys.count == 0 {
            displayBackgroundMessage("Be the first to post in this area!", label: noThreadsLabel, viewToAdd: tableView, height: 90, textSize: 17)
        } else {
            removeBackgroundMessage(noThreadsLabel)
        }
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
    
    func threadChanged(thread: Thread){
        if let index = threads.indexOf({$0.key == thread.key}) {
            thread.downloadThread(){thread in
                self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: index, inSection: 0)], withRowAnimation: UITableViewRowAnimation.None)
            }
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ThreadCell", forIndexPath: indexPath) as! PostCell
        let key = threadKeys[indexPath.row]
        if let index = threads.indexOf({$0.key == key}) {
            cell.configureCell(threads[index].originalPost, type: "threads", extra: threads[index], isPeekLocation: isPeekLocation)
        } else {
            cell.downloadThreadAndConfigure(key, isPeekLocation: isPeekLocation) {thread in
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
            NSUserDefaults.standardUserDefaults().setObject(location.coordinate.latitude, forKey: "LAST_LATITUDE")
            NSUserDefaults.standardUserDefaults().setObject(location.coordinate.longitude, forKey: "LAST_LONGITUDE")
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
        textView.textColor = DARK_GREY_TEXT_COLOR
        if textView.text == "What's up?" {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.lightGrayColor()
            textView.text = "What's up?"
        } else {
            textView.textColor = DARK_GREY_TEXT_COLOR
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
    
    func saveAsBasecamp(){
        guard let currentLocation = currentLocation else { return }
        guard let basecampName = peekLocationName else { return }
        firebase = FIRDatabase.database().reference()
        firebase.child("basecamps").child(uid).child("name").setValue(basecampName)
        firebase.child("basecamps").child(uid).child("latitude").setValue(currentLocation.coordinate.latitude)
        firebase.child("basecamps").child(uid).child("longitude").setValue(currentLocation.coordinate.longitude)
        if let navController = self.navigationController {
            if let exploreVC = navController.viewControllers[0] as? ExploreVC {
                navController.popToRootViewControllerAnimated(true)
                exploreVC.setBasecamp(currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude, name: basecampName)
            }
        }
    }
    
    func savePeekLocation(){
        
    }
    
    @IBAction func onBannerButtonPressed(sender: AnyObject) {
        if isBasecampOption {
            let alert = UIAlertController(title: "Save As Basecamp", message: "Are you sure you want to save this location as your basecamp? This can only be done once.", preferredStyle: .Alert)
            
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Default) { action -> Void in
            }
            alert.addAction(cancel)
            
            let add = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default) { action -> Void in
                self.saveAsBasecamp()
            }
            alert.addAction(add)
            
            self.presentViewController(alert, animated: true, completion: nil)
        } else {
            savePeekLocation()
        }
    }
    
    @IBAction func onBackButtonPressed(sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "threadVCFromHome" {
            if let destinationVC = segue.destinationViewController as? ThreadVC {
                destinationVC.delegate = self
                destinationVC.thread = sender as? Thread
                destinationVC.isPeekLocation = isPeekLocation
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
