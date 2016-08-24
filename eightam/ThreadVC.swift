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

class ThreadVC: UIViewController {

    @IBOutlet weak var opTextView: UITextView!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var numCommentsLabel: UILabel!
    @IBOutlet weak var timeLabel: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var replyInput: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    
    var thread: Thread!
    
    var swiper: SloppySwiper!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        hideKeyboardWhenTappedAround()
        
        if let navigationcontroller = self.navigationController {
            swiper = SloppySwiper(navigationController: navigationcontroller)
            navigationcontroller.delegate = swiper
        }
        
        replyInput.layer.sublayerTransform = CATransform3DMakeTranslation(5, 0, 0)
        
        opTextView.text = thread.opText
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.hidden = true
    }
    
    override func viewDidDisappear(animated: Bool) {
        self.tabBarController?.tabBar.hidden = false
    }

    @IBAction func onSendButtonPressed(sender: AnyObject) {
    }

    @IBAction func onBackButtonPressed(sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }
}
