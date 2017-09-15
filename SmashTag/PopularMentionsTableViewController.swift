//
//  PopularMentionsTableViewController.swift
//  SmashTag
//
//  Created by Gianni Maize on 9/14/17.
//  Copyright © 2017 Maize Man. All rights reserved.
//

import UIKit
import CoreData
import Twitter

class PopularMentionsTableViewController: FetchedResultsTableViewController {
	
	var searchText: String? { didSet { updateUI() }}
	
	var container: NSPersistentContainer? = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer { didSet { updateUI() }}
	
	fileprivate var fetchedResultsController: NSFetchedResultsController<Mention>?
	
	private func updateUI() {
		if let context = container?.viewContext, searchText != nil {
			let request : NSFetchRequest<Mention> = Mention.fetchRequest()
			request.sortDescriptors = [NSSortDescriptor(key: "count", ascending: false),
			                           NSSortDescriptor(key: "keyword", ascending: true)]
			request.predicate = NSPredicate(format: "any query.text = %@ and count > 1", searchText!)
			fetchedResultsController = NSFetchedResultsController<Mention>(
				fetchRequest: request,
				managedObjectContext: context,
				sectionNameKeyPath: nil,
				cacheName: nil
			)
			try? fetchedResultsController?.performFetch()
			tableView.reloadData()
		}
	
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Popular Mention Cell", for: indexPath)
		
		if let mention = fetchedResultsController?.object(at: indexPath) {
			cell.textLabel?.text = mention.keyword
			cell.detailTextLabel?.text = "\(mention.count) mentions"
		}
		return cell
	}

}

//
//  UITableViewController extension for use with NSFetchedResultsController
//
//  Created by CS193p Instructor.
//  Copyright © 2017 Stanford University. All rights reserved.
//
//  This implements the UITableViewDataSources
//  assuming a var called fetchedResultsController exists

extension PopularMentionsTableViewController
{
	// MARK: UITableViewDataSource
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return fetchedResultsController?.sections?.count ?? 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let sections = fetchedResultsController?.sections, sections.count > 0 {
			return sections[section].numberOfObjects
		} else {
			return 0
		}
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if let sections = fetchedResultsController?.sections, sections.count > 0 {
			return sections[section].name
		} else {
			return nil
		}
	}
	
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return fetchedResultsController?.sectionIndexTitles
	}
	
	override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return fetchedResultsController?.section(forSectionIndexTitle: title, at: index) ?? 0
	}
	
}

