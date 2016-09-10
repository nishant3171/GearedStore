//
//  ViewController.swift
//  GearedStore
//
//  Created by Nishant Punia on 09/09/16.
//  Copyright © 2016 MLBNP. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var searchResults = [SearchStore]()
    var hasSearched = false
    
    struct tableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 44.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.rowHeight = 90.0
        
        var cellNib = UINib(nibName: tableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: tableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: tableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: tableViewCellIdentifiers.nothingFoundCell)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchResults = [SearchStore]()
        hasSearched = true
        
        if searchBar.text != "justin bieber" {
        for i in 0...2 {
           let searchResult = SearchStore()
            searchResult.name = String(format: "Fake results %d for", i)
            searchResult.artistName = searchBar.text!
            searchResults.append(searchResult)
        }
        }
        tableView.reloadData()
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        }else if searchResults.count == 0 {
        return 1
        } else {
        return searchResults.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if searchResults.count == 0 {
            return tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
        } else {
        let cell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
        let searchResult = searchResults[indexPath.row]
        cell.nameLabel?.text = searchResult.name
        cell.artistNameLabel?.text = searchResult.artistName
        return cell
        }
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if searchResults.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
}

