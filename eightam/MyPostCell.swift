//
//  MyPostCell.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-29.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import UIKit

class MyPostCell: UITableViewCell {

    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func configureCell(post: Post){
        guard let text = post.text else { return }
        guard let time = post.time else { return }
        postTextLabel.text = "\"\(text)\""
        timeLabel.text = "\(getPostTime(time).0)\(getPostTime(time).1)"
    }
    
    func downloadAndConfigureCell(key: String, type: String, completion: (AnyObject)->()){
        if type == "My Threads" {
            let thread = Thread(key: key)
            thread.downloadThread(){ thread in
                self.configureCell(thread.originalPost)
                completion(thread)
            }
        } else {
            let post = Post(key: key)
            post.downloadPost(){ post in
                self.configureCell(post)
                completion(post)
            }
        }
    }
}
