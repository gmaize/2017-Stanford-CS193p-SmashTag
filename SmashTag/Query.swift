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
	class func findOrCreateQuery(matching searchText: String, with tweets: [Twitter.Tweet]?, in context: NSManagedObjectContext) throws -> Query {
		let request : NSFetchRequest<Query> = Query.fetchRequest()
		request.predicate = NSPredicate(format: "text = %@", searchText)
		
		do {
			let matches = try context.fetch(request)
			if matches.count > 0 {
				assert(matches.count == 1, "Query.findOrCreateQuery -- database inconsistency.")
				return matches[0]
			}
		} catch {
			throw error
		}
		
		let query = Query(context: context)
		query.text = searchText
		if tweets == nil {
			return query
		}
		var queryTweets = Array<Tweet>()
		var queryMentions = Array<Mention>()
		for tweet in tweets! {
			let queryTweet = try? Tweet.findOrCreateTweet(matching: tweet, in: context)
			if queryTweet == nil {
				continue
			}
			queryTweets.append(queryTweet!)
			for mention in tweet.hashtags + tweet.userMentions {
				let queryMention = try? Mention.findOrCreateMention(matching: mention, in: context)
				if queryMention == nil {
					continue
				}
				queryMentions.append(queryMention!)
			}
		}
		query.mentions = NSSet(array: queryMentions)
		query.tweets = NSSet(array: queryTweets)
		return query
	}

}
