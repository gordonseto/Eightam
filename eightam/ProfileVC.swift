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
        settings.style.selectedBarBackgroundColor = UIColor(red: 33/255.0, green: 174/255.0, blue: 67/255.0, alpha: 1.0)
        settings.style.buttonBarItemFont = UIFont(name: "HelveticaNeue", size:14) ?? UIFont.systemFontOfSize(14)
        settings.style.selectedBarHeight = 3.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = BLUE_COLOR
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        
        settings.style.buttonBarLeftContentInset = 20
        settings.style.buttonBarRightContentInset = 20
        
        changeCurrentIndexProgressive = { (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = UIColor(red: 138/255.0, green: 138/255.0, blue: 144/255.0, alpha: 1.0)
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
