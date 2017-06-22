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
    
    private func attributeTweetMentions(_ attributeName: String, _ attributeValue: Any, _ attributedText: NSMutableAttributedString, _ mentions: [Twitter.Mention]) {
        for mention in mentions {
            print(mention.description)
            attributedText.addAttribute(attributeName, value: attributeValue, range: mention.nsrange)
        }
    }
    
    private func updateUI() {
        tweetUserLabel?.text = tweet?.user.name
        var mentionColors: [String: UIColor] = ["hashtag": UIColor.magenta, "url": UIColor.blue, "userMention": UIColor.purple]
        let attributedTweetText = NSMutableAttributedString(string: (tweet?.text)!)
        attributeTweetMentions(NSForegroundColorAttributeName, mentionColors["hashtag"] as Any, attributedTweetText, (tweet?.hashtags)!)
        attributeTweetMentions(NSForegroundColorAttributeName, mentionColors["url"] as Any, attributedTweetText, (tweet?.urls)!)
        attributeTweetMentions(NSForegroundColorAttributeName, mentionColors["userMention"] as Any, attributedTweetText, (tweet?.userMentions)!)
        tweetTextLabel?.attributedText = attributedTweetText
        if let profileImageURL = tweet?.user.profileImageURL {
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                if let imageData = try? Data(contentsOf: profileImageURL), profileImageURL == self?.tweet?.user.profileImageURL{
                    DispatchQueue.main.async {
                        self?.tweetProfileImageView?.image = UIImage(data: imageData)
                    }
                } else if profileImageURL == self?.tweet?.user.profileImageURL {
                    DispatchQueue.main.async {
                        self?.tweetProfileImageView?.image = nil
                    }
                }
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
