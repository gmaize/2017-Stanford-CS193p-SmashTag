//
//  Mention.swift
//  SmashTag
//
//  Created by Gianni Maize on 9/13/17.
//  Copyright © 2017 Maize Man. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class Mention: NSManagedObject {
	class func findOrCreateMention(from mentionInfo: Twitter.Mention, for searchText: String, in context: NSManagedObjectContext) throws -> Mention {
		let request : NSFetchRequest<Mention> = Mention.fetchRequest()
		request.predicate = NSPredicate(format: "keyword = %@ and query.text = %@", mentionInfo.keyword.lowercased(), searchText.lowercased())
		
		do {
			let matches = try context.fetch(request)
			if matches.count > 0 {
				assert(matches.count == 1, "Mention.findOrCreateMention -- database inconsistency.")
				matches[0].count += 1
				return matches[0]
			}
		} catch {
			throw error
		}
		
		let mention = Mention(context: context)
		mention.keyword = mentionInfo.keyword.lowercased()
		mention.count = 1
		return mention
	}
}
