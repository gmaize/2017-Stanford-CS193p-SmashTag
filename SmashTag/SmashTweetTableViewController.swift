//
//  SmashTweetTableViewController.swift
//  SmashTag
//
//  Created by Gianni Maize on 9/13/17.
//  Copyright © 2017 Maize Man. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class SmashTweetTableViewController: TweetTableViewController {

	var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer
	
	override func insertTweets(_ newTweets: [Twitter.Tweet]) {
		super.insertTweets(newTweets)
		updateDatabase(with: newTweets)
	}
	
	private func updateDatabase(with tweets: [Twitter.Tweet]) {
		container?.performBackgroundTask{ [weak self] context in
			var tweets = Array<Twitter.Tweet>()
			if self?.tweets != nil {
				for section in self?.tweets ?? [] {
					tweets += section
				}
			}
			_ = try? Query.findOrCreateQuery(matching: self?.searchText ?? "", with: tweets, in: context)
			try? context.save()
			self?.printDatabaseStatistics()
		}
	}
	
	private func printDatabaseStatistics() {
		if let context = container?.viewContext {
			context.perform {
				let request1: NSFetchRequest<Tweet> = Tweet.fetchRequest()
				if let tweetCount = (try? context.fetch(request1))?.count {
					print("\(tweetCount) tweets")
				}
				let request2: NSFetchRequest<Query> = Query.fetchRequest()
				if let queryCount = (try? context.fetch(request2))?.count {
					print("\(queryCount) queries")
				}
				let request3: NSFetchRequest<Mention> = Mention.fetchRequest()
				if let mentionCount = (try? context.fetch(request3))?.count {
					print("\(mentionCount) mentions")
				}
			}
		}
	}
}
