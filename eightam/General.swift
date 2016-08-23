//
//  General.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-23.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import Foundation
import UIKit

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

func bounceView(view: UIView){
    UIView.animateWithDuration(0.1, delay: 0.0, options: [], animations: {
        view.transform = CGAffineTransformMakeScale(1.1, 1.1)
        }, completion: {completed in
            UIView.animateWithDuration(0.1, delay: 0.0, options: [], animations: {
                view.transform = CGAffineTransformMakeScale(1.0, 1.0)
                }, completion: {completed in })
    })
}