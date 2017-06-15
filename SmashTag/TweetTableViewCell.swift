//
//  TweetTableViewCell.swift
//  SmashTag
//
//  Created by Gianni Maize on 6/15/17.
//  Copyright © 2017 Maize Man. All rights reserved.
//

import UIKit
import Twitter

class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tweetProfileImageView: UIImageView!
    @IBOutlet weak var tweetUserLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetCreatedLabel: UILabel!
    
    /* Public API for updating cell's content */
    var tweet: Twitter.Tweet? {
        didSet {
            updateUI()
        }
    }
    
    private func updateUI() {
        tweetUserLabel?.text = tweet?.user.name
        tweetTextLabel?.text = tweet?.text
        if let profileImageURL = tweet?.user.profileImageURL {
            //FIXME blocks main thread
            if let imageData = try? Data(contentsOf: profileImageURL) {
                tweetProfileImageView?.image = UIImage(data: imageData)
            } else {
                tweetProfileImageView?.image = nil
            }
        }
        if let created = tweet?.created {
            let formatter = DateFormatter()
            if Date().timeIntervalSince(created) > 24*60*60 {
                formatter.dateStyle = .short
            } else {
                formatter.timeStyle = .short
            }
            tweetCreatedLabel?.text = formatter.string(from: created)
        } else {
            tweetCreatedLabel?.text = nil
        }
    }
    
}
