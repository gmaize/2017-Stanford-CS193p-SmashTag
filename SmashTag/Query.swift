//
//  Query.swift
//  SmashTag
//
//  Created by Gianni Maize on 9/13/17.
//  Copyright © 2017 Maize Man. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class Query: NSManagedObject {
	class func findOrCreateQuery(matching searchText: String, with twitterTweets: [Twitter.Tweet], in context: NSManagedObjectContext) throws -> Query {
		let request : NSFetchRequest<Query> = Query.fetchRequest()
		request.predicate = NSPredicate(format: "text = %@", searchText.lowercased())
		let query: Query
		do {
			let matches = try context.fetch(request)
			if matches.count > 0 {
				assert(matches.count == 1, "Query.findOrCreateQuery -- database inconsistency.")
				query = matches[0]
			} else {
				query = Query(context: context)
				query.text = searchText
			}
		} catch {
			throw error
		}
		for tweetInfo in twitterTweets {
			let tweet = try? Tweet.findOrCreateTweet(with: tweetInfo, in: context)
			if tweet != nil, !(query.tweets?.contains(tweet!))! {
				query.addToTweets(tweet!)
				for mentionInfo in tweetInfo.hashtags + tweetInfo.userMentions {
					let mention = try? Mention.findOrCreateMention(from: mentionInfo, for: searchText.lowercased(), in: context)
					if mention != nil, !(query.mentions?.contains(mention!))! {
						query.addToMentions(mention!)
					}
				}
			}
		}
		return query
	}

}
