//
//  ReplyView.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-24.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import UIKit

class ReplyView: UIView {

    override func awakeFromNib() {
        super.awakeFromNib()
        
        var topBorder = CALayer()
        topBorder.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.size.width, height: 1.0)
        topBorder.backgroundColor = UIColor(red: 225.0/255.0, green: 225.0/255.0, blue: 225.0/255.0, alpha: 1.0).CGColor
        
        self.layer.addSublayer(topBorder)
    
    }

}
