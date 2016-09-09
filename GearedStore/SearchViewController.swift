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
    
    var searchStrings = [SearchStore]()
    var hasSearched = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 44.0, left: 0.0, bottom: 0.0, right: 0.0)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchStrings = [SearchStore]()
        hasSearched = true
        
        if searchBar.text != "justin bieber" {
        for i in 0...2 {
           let searchString = SearchStore()
            searchString.name = String(format: "Fake results %d for", i)
            searchString.artistName = searchBar.text!
            searchStrings.append(searchString)
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
        }else if searchStrings.count == 0 {
        return 1
        } else {
        return searchStrings.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cellIdentifier = "SearchResultCell"
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(cellIdentifier)
        
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: cellIdentifier)
        }
        
        
        if searchStrings.count == 0 {
            cell.textLabel?.text = "Nothing found"
            cell.detailTextLabel?.text = ""
        } else {
        let searchString = searchStrings[indexPath.row]
        cell.textLabel?.text = searchString.name
        cell.detailTextLabel?.text = searchString.artistName
        }
        return cell
    }
}

extension SearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if searchStrings.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
}

