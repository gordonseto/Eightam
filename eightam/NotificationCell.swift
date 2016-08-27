//
//  NotificationCell.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-27.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import UIKit

class NotificationCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var notificationCellView: UIView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func configureCell(notification: Notification) {
        messageLabel.textColor = DARK_GREY_TEXT_COLOR
        timeLabel.textColor = DARK_GREY_TEXT_COLOR
        if let message = notification.message {
            messageLabel.text = message
        }
        if let time = notification.time {
            timeLabel.text = "\(getPostTime(time).0)\(getPostTime(time).1)"
        }
        if let seen = notification.seen {
            if seen {
                messageLabel.font = UIFont(name: "HelveticaNeue", size: 15)
                timeLabel.font = UIFont(name: "HelveticaNeue", size: 13)
            } else {
                messageLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 15)
                timeLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 13)
            }
        }
    }
}
