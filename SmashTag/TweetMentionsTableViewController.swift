//
//  TweetMentionsTableViewController.swift
//  SmashTag
//
//  Created by Gianni Maize on 6/18/17.
//  Copyright © 2017 Maize Man. All rights reserved.
//

import UIKit
import Twitter

class TweetMentionsTableViewController: UITableViewController {
    
    public var tweet: Twitter.Tweet? {
        didSet {
            title = (tweet != nil) ? "@\(tweet!.user.screenName)" : "Mentions"
            mentionGroups.removeAll()
            tableView?.reloadData()
            if let media = tweet?.media, media.count > 0 {
                let mentionItems = media.map { MentionItem.image($0.url, $0.aspectRatio) }
                mentionGroups.append(MentionGroup(title: "\(MentionsGroupSectionName.images.rawValue)", data: mentionItems))
                tableView?.insertSections([mentionGroups.count-1], with: .fade)
            }
            if let hashtags = tweet?.hashtags, hashtags.count > 0 {
                let mentionItems = hashtags.map { MentionItem.keyword($0.keyword) }
                mentionGroups.append(MentionGroup(title: "\(MentionsGroupSectionName.hashtags.rawValue)", data: mentionItems))
                tableView?.insertSections([mentionGroups.count-1], with: .fade)
            }
            if let users = tweet?.userMentions, users.count > 0 {
                let mentionItems = users.map { MentionItem.keyword($0.keyword) }
                mentionGroups.append(MentionGroup(title: "\(MentionsGroupSectionName.users.rawValue)", data: mentionItems))
                tableView?.insertSections([mentionGroups.count-1], with: .fade)
            }
            if let urls = tweet?.urls, urls.count > 0 {
                let mentionItems = urls.map { MentionItem.url($0.keyword) }
                mentionGroups.append(MentionGroup(title: "\(MentionsGroupSectionName.urls.rawValue)", data: mentionItems))
                tableView?.insertSections([mentionGroups.count-1], with: .fade)
            }
        }
    }
    
    private var mentionGroups: [MentionGroup] = [MentionGroup]()
    
    private enum MentionItem {
        case image(URL, Double) //image URL and aspect ratio
        case keyword(String) //hashtag or user (keyword is included, e.g. "#surfing" or "@ginobeb")
        case url(String) //web url
        
        var description: String {
            get {
                switch (self) {
                case .image(let url, _):
                    return url.absoluteString
                case .keyword(let description), .url(let description):
                    return description
                }
            }
        }
    }
    
    private struct MentionGroup {
        var title: String
        var data: [MentionItem]
    }
    
    private enum MentionsTableCellIdentifier: String {
        case textBased = "TextBasedMentionCell"
        case imageBased = "ImageMentionCell"
    }
    
    private enum MentionsGroupSectionName: String {
        case images = "Images"
        case hashtags = "Hashtags"
        case users = "Users"
        case urls = "Urls"
    }
    
    // MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // we use the row height in the storyboard as an "estimate"
        tableView.estimatedRowHeight = tableView.rowHeight
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return mentionGroups.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentionGroups[section].data.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return mentionGroups[section].title
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let mentionItem = mentionGroups[indexPath.section].data[indexPath.row]
        switch mentionItem {
        case .image(_, let aspectRatio):
            return tableView.bounds.size.width / CGFloat(aspectRatio)
        case .keyword, .url:
            return UITableViewAutomaticDimension
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let mentionItem = mentionGroups[indexPath.section].data[indexPath.row]
        switch mentionItem {
        case .image(let imgURL, _):
            //grab available Image cell container
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(MentionsTableCellIdentifier.imageBased.rawValue)", for: indexPath)
            //get the image url associated with this section & row
            if let imageMentionCell = cell as? TweetImageMentionTableViewCell {
                imageMentionCell.imgURL = imgURL //set the image cell's content
            }
            return cell
        case .keyword, .url:
            let cell = tableView.dequeueReusableCell(withIdentifier: "\(MentionsTableCellIdentifier.textBased.rawValue)", for: indexPath)
            cell.textLabel?.text = mentionItem.description
            return cell
        }
    }
    
     // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        switch(identifier) {
        case "searchForTweets":
            if let cell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: cell) {
                let mentionItem = mentionGroups[indexPath.section].data[indexPath.row]
                switch (mentionItem) {
                case .url(let url):
                    if #available(iOS 10.0, *),
                        let url = URL(string: url){
                        UIApplication.shared.open(url)
                    } else if let url = URL(string: url) {
                        UIApplication.shared.openURL(url)
                    }
                    return false
                default: break
                }

            }
        default: break
        }
        return true
    }

     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var destinationVC = segue.destination
        if let navigationVC = destinationVC as? UINavigationController {
            destinationVC = navigationVC.visibleViewController ?? destinationVC
		} else if let tabBarVC = destinationVC as? UITabBarController {
			destinationVC = tabBarVC.viewControllers![0]
		}
        if let segueID = segue.identifier {
            if segueID == "searchForTweets",
                let selectedMentionCell = sender as? UITableViewCell,
                let indexPath = tableView.indexPath(for: selectedMentionCell),
                let tweetsTableVC = destinationVC as? TweetTableViewController {
                let mentionItem = mentionGroups[indexPath.section].data[indexPath.row]
                tweetsTableVC.searchText = mentionItem.description
            } else if segueID == "viewImage",
                let selectedImageCell = sender as? TweetImageMentionTableViewCell,
                let indexPath = tableView.indexPath(for: selectedImageCell),
                let imageVC = destinationVC as? ImageViewController {
                let imageMentionItem = mentionGroups[indexPath.section].data[indexPath.row]
                imageVC.imageURL = URL(string: imageMentionItem.description)
            }
        }
     }
}
