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
    
    //MARK: Variables
    var searchResults = [SearchStore]()
    var hasSearched = false
    var isLoading = false
    
    struct tableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 44.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.rowHeight = 90.0
        
        var cellNib = UINib(nibName: tableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: tableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: tableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: tableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: tableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: tableViewCellIdentifiers.loadingCell)
        
        searchBar.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

    func urlWithSearchString(searchString: String) -> NSURL {
        let escapedSearchString = searchString.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", escapedSearchString)
        let url = NSURL(string: urlString)
        return url!
    }

    func performStoreRequest(url: NSURL) -> String? {
        do {
            return try String(contentsOfURL: url, encoding: NSUTF8StringEncoding)
        } catch {
            print("Download error: \(error)")
            return nil
        }
    
    }

    func parseJson(jsonString: String) -> [String: AnyObject]? {
    
        guard let data = jsonString.dataUsingEncoding(NSUTF8StringEncoding)
            else {
                return nil
            }
        do {
            return try NSJSONSerialization.JSONObjectWithData(data, options: []) as? [String: AnyObject]
        } catch {
            print("Error: \(error).")
            return nil
        }
    }

    func showNetworkError(viewController: UIViewController) -> Void {
    
        let alert = UIAlertController(title: "Oops...!", message: "Failed to read from iTunes Store.", preferredStyle: .Alert)
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        viewController.presentViewController(alert, animated: true, completion: nil)
    
    }

    func parseDictionary(dictionary: [String: AnyObject]) -> [SearchStore] {
        
        guard let array = dictionary["results"] as? [AnyObject] else {
            print("Expected 'results' array.")
            return []
        }
        
        var searchResults = [SearchStore]()
        
        for resultDict in array {
            if let resultDict = resultDict as? [String: AnyObject] {
                var searchResult: SearchStore?
                
                if let wrapperType = resultDict["wrapperType"] as? String {
                    switch wrapperType {
                        case "track":
                        searchResult = parseTrack(resultDict)
                        case "audiobook":
                        searchResult = parseAudioBook(resultDict)
                        case "software":
                        searchResult = parseSoftware(resultDict)
                    default:
                        break
                    }
                } else if let kind = resultDict["kind"] as? String where kind == "ebook" {
                    searchResult = parseEBook(resultDict)
                }
                if let result = searchResult {
                    searchResults.append(result)
                }
            }
        }
        return searchResults
}

    func parseTrack(dictionary: [String: AnyObject]) -> SearchStore {
        let searchResult = SearchStore()
        
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        
        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        
        return searchResult
    }

func parseAudioBook(dictionary: [String: AnyObject]) -> SearchStore {
    let searchResult = SearchStore()
    searchResult.name = dictionary["collectionName"] as! String
    searchResult.artistName = dictionary["artistName"] as! String
    searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
    searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
    searchResult.storeURL = dictionary["collectionViewUrl"] as! String
    searchResult.kind = "audiobook"
    searchResult.currency = dictionary["currency"] as! String
    
    if let price = dictionary["collectionPrice"] as? Double {
        searchResult.price = price
    }
    if let genre = dictionary["primaryGenreName"] as? String {
        searchResult.genre = genre
    }
    return searchResult
}

    func parseSoftware(dictionary: [String: AnyObject]) -> SearchStore {
        let searchResult = SearchStore()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? Double {
        searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
        searchResult.genre = genre
        }
        return searchResult
    }

    func parseEBook(dictionary: [String: AnyObject]) -> SearchStore {
        let searchResult = SearchStore()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkURL60 = dictionary["artworkUrl60"] as! String
        searchResult.artworkURL100 = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
    
        if let price = dictionary["price"] as? Double {
        searchResult.price = price
        }
        if let genres: AnyObject = dictionary["genres"] {
        searchResult.genre = (genres as! [String]).joinWithSeparator(", ")
        }
        return searchResult
    }

    func kindForDisplay(kind: String) -> String {
        switch kind {
        case "album": return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie" case "music-video": return "Music Video" case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default: return kind
        }
    }

//MARK: SearchBar Extension
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            isLoading = true
            tableView.reloadData()
            
            hasSearched = true
            searchResults = [SearchStore]()
            
            
            let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
            
            dispatch_async(queue) {
                let url = urlWithSearchString(searchBar.text!)
                
                if let jsonString = performStoreRequest(url) {
                    
                    if let dictionary = parseJson(jsonString) {
                        self.searchResults = parseDictionary(dictionary)
                        self.searchResults.sortInPlace{ $0 < $1}
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                        return
                    }
            }
            
                dispatch_async(dispatch_get_main_queue()) {
                    showNetworkError(self)
                }
            }
        }
    }
    
    
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}

//MARK: TableViewDataSource
extension SearchViewController: UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading {
            return 1
        } else if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
        return 1
        } else {
        return searchResults.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if isLoading {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifiers.loadingCell, forIndexPath: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
            
        } else if searchResults.count == 0 {
            
            return tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath)
            
        } else {
            
        let cell = tableView.dequeueReusableCellWithIdentifier(tableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
        let searchResult = searchResults[indexPath.row]
        cell.nameLabel?.text = searchResult.name
        cell.artistNameLabel?.text = String(format: "%@ (%@)", searchResult.artistName,kindForDisplay(searchResult.kind))
        return cell
            
        }
    }
}

//MARK: TableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        } else {
            return indexPath
        }
    }
}

