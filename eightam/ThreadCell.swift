//
//  ThreadCell.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-23.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import UIKit

class ThreadCell: UITableViewCell {

    @IBOutlet weak var opTextView: UITextView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var numCommentsLabel: UILabel!
    @IBOutlet weak var pointsLabel: UILabel!
    @IBOutlet weak var upButton: UIButton!
    @IBOutlet weak var downButton: UIButton!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func configureCell(thread: Thread){
        print(thread.opText)
        guard let opText = thread.opText else { return }
        guard let time = thread.time else { return }
        guard let numComments = thread.numComments else { return }
        guard let points = thread.points else { return }
        
        
        opTextView.text = opText
        numCommentsLabel.text = "\(numComments) replies"
        pointsLabel.text = "\(points)"
    }
    
    func downloadThreadAndConfigure(threadKey: String, completion: (Thread)->()) {
        let thread = Thread(key: threadKey)
        thread.downloadThread(){ thread in
            self.configureCell(thread)
            completion(thread)
        }
    }
    
    @IBAction func onUpButtonTapped(sender: UIButton) {
        print("hi")
    }
    
    @IBAction func onDownButtonTapped(sender: UIButton) {
        print ("yo")
    }

}
