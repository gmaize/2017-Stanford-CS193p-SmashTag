//
//  RecentTermsTableViewController.swift
//  SmashTag
//
//  Created by Gianni Maize on 9/4/17.
//  Copyright © 2017 Maize Man. All rights reserved.
//

import UIKit

class RecentTermsTableViewController: UITableViewController {

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}
	
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RecentSearchTerms.getTerms().count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTerm", for: indexPath)
		cell.textLabel?.text = RecentSearchTerms.getTerms()[indexPath.row]
        return cell
    }
	
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		var destinationViewController = segue.destination
		if let tabBarViewController = destinationViewController as? UITabBarController {
			destinationViewController = tabBarViewController.viewControllers![0]
		}
		if segue.identifier == "Show Popular Mentions",
			let selectedMentionCell = sender as? UITableViewCell,
			let indexPath = tableView.indexPath(for: selectedMentionCell),
			let popularMentionsTableVC = destinationViewController as? PopularMentionsTableViewController {
				let searchTerm = RecentSearchTerms.getTerms()[indexPath.row]
				popularMentionsTableVC.searchText = searchTerm

		} else if let selectedMentionCell = sender as? UITableViewCell,
			let indexPath = tableView.indexPath(for: selectedMentionCell),
			let tweetsTableVC = destinationViewController as? TweetTableViewController {
				let searchTerm = RecentSearchTerms.getTerms()[indexPath.row]
				tweetsTableVC.searchText = searchTerm
		}
	}
}
