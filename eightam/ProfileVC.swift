//
//  ProfileVC.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-29.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SloppySwiper

class ProfileVC: ButtonBarPagerTabStripViewController {

    var swiper: SloppySwiper!
    
    override func viewDidLoad() {
        
        self.navigationController?.navigationBarHidden = true
        
        if let navigationcontroller = self.navigationController {
            swiper = SloppySwiper(navigationController: navigationcontroller)
            navigationcontroller.delegate = swiper
        }
        
        // change selected bar color
        settings.style.buttonBarBackgroundColor = BLUE_COLOR
        settings.style.buttonBarItemBackgroundColor = BLUE_COLOR
        settings.style.selectedBarBackgroundColor = UIColor.whiteColor()
        settings.style.buttonBarItemFont = UIFont(name: "HelveticaNeue-Bold", size:14) ?? UIFont.systemFontOfSize(14)
        settings.style.selectedBarHeight = 3.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = BLUE_COLOR
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        
        settings.style.buttonBarLeftContentInset = 20
        settings.style.buttonBarRightContentInset = 20
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor.lightGrayColor()
            newCell?.label.textColor = .whiteColor()
        }
        super.viewDidLoad()
    }

    override func viewControllersForPagerTabStrip(pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {
        let myThreadsVC = self.storyboard?.instantiateViewControllerWithIdentifier("EmbeddedProfileVC") as! EmbeddedProfileVC
        myThreadsVC.type = "My Threads"
        let myRepliesVC = self.storyboard?.instantiateViewControllerWithIdentifier("EmbeddedProfileVC") as! EmbeddedProfileVC
        myRepliesVC.type = "My Replies"
        myRepliesVC.view.backgroundColor = UIColor.redColor()
        return [myThreadsVC, myRepliesVC]
    }
}
