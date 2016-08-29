//
//  EmbeddedProfileVC.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-29.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import UIKit
import XLPagerTabStrip

class EmbeddedProfileVC: UIViewController, IndicatorInfoProvider {

    var type: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    func indicatorInfoForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: type)
    }
}
