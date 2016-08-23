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

class HomeVC: UIViewController, CLLocationManagerDelegate, UITextViewDelegate {

    @IBOutlet weak var newPostTextView: UITextView!
    @IBOutlet weak var characterCountLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var sendButton: UIBarButtonItem!
    
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation!
    
    var hasLoadedThreads: Bool = false
    
    var uid: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        newPostTextView.delegate = self
        
        let numberToolbar = UIToolbar(frame: CGRectMake(0, 0, self.view.frame.size.width, 50))
        numberToolbar.barStyle = UIBarStyle.Default
        
        sendButton = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(HomeVC.onKeyboardSendTapped(_:)))
        sendButton.tintColor = UIColor.blackColor()
        sendButton.setTitleTextAttributes([NSFontAttributeName: UIFont(name: "HelveticaNeue-Bold", size: 16.0)!], forState: UIControlState.Normal)
        
        numberToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil),
            sendButton]
        numberToolbar.sizeToFit()
        newPostTextView.inputAccessoryView = numberToolbar
        
        locationManager.delegate = self
        
        if let uid = FIRAuth.auth()?.currentUser?.uid {
            self.uid = uid
            beginHomeVC()
        }
    }
    
    func beginHomeVC(){
        locationAuthStatus()
    }
    
    func postNewThread(){
        guard let uid = uid else { return }
        guard let currentLocation = currentLocation else { return }
        guard let text = newPostTextView.text where text != "" || text != "What's up?" else { return }
        
        newPostTextView.userInteractionEnabled = false
        let thread = Thread(authorUid: uid, text: text, geolocation: currentLocation)
        //thread.newThread()
        thread.postThread().continueWith { task in
            if task.faulted {
                print("post failed")
            } else {
                print(task.result)
                self.newPostTextView.textColor = UIColor.lightGrayColor()
                self.newPostTextView.text = "What's up?"
                self.newPostTextView.userInteractionEnabled = true
            }
        }
    }
    
    func onKeyboardSendTapped(sender: AnyObject){
        newPostTextView.resignFirstResponder()
        postNewThread()
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            //print(location)
            self.currentLocation = location
            if !hasLoadedThreads {
                
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
        textView.textColor = UIColor.blackColor()
        if textView.text == "What's up?" {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if textView.text == "" {
            textView.textColor = UIColor.lightGrayColor()
            textView.text = "What's up?"
        } else {
            textView.textColor = UIColor.blackColor()
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        characterCountLabel.text = "\(MAX_TEXT - textView.text.characters.count)"
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
