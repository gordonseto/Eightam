//
//  ExploreVC.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-25.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import UIKit

class ExploreVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.navigationBarHidden = true
    }

    @IBAction func onBasecampTapped(sender: AnyObject) {
        print("hi")
        performSegueWithIdentifier("mapVCFromBasecamp", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "mapVCFromBasecamp" {
            
        }
    }
    
}
