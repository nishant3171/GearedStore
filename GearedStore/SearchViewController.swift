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
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBAction func segmentChanged(sender: UISegmentedControl) {
        performSearch()
    }
    
    
    //MARK: Variables
    var searchResults = [SearchStore]()
    var hasSearched = false
    var isLoading = false
    var dataTask: URLSessionDataTask?
    
    struct tableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.contentInset = UIEdgeInsets(top: 88.0, left: 0.0, bottom: 0.0, right: 0.0)
        tableView.rowHeight = 90.0
        
        var cellNib = UINib(nibName: tableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: tableViewCellIdentifiers.searchResultCell)
        
        cellNib = UINib(nibName: tableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: tableViewCellIdentifiers.nothingFoundCell)
        
        cellNib = UINib(nibName: tableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: tableViewCellIdentifiers.loadingCell)
        
        searchBar.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

    func urlWithSearchString(searchString: String, category: Int) -> NSURL {
        
        let entityName: String
        switch category {
        case 1: entityName = "musicTrack"
        case 2: entityName = "software"
        case 3: entityName = "ebook"
        default: entityName = ""
        }

        let escapedSearchString = searchString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlUserAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&entity=%@", escapedSearchString,entityName)
        let url = NSURL(string: urlString)
        return url!
    }

    func parseJson(data: NSData) -> [String: AnyObject]? {
    
        do {
            return try JSONSerialization.jsonObject(with: data as Data, options: []) as? [String: AnyObject]
        } catch {
            print("Error: \(error).")
            return nil
        }
    }

    func showNetworkError(viewController: UIViewController) -> Void {
    
        let alert = UIAlertController(title: "Oops...!", message: "Failed to read from iTunes Store.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        viewController.present(alert, animated: true, completion: nil)
    
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
                        searchResult = parseTrack(dictionary: resultDict)
                        case "audiobook":
                        searchResult = parseAudioBook(dictionary: resultDict)
                        case "software":
                        searchResult = parseSoftware(dictionary: resultDict)
                    default:
                        break
                    }
                } else if let kind = resultDict["kind"] as? String , kind == "ebook" {
                    searchResult = parseEBook(dictionary: resultDict)
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
        searchResult.genre = (genres as! [String]).joined(separator: ", ")
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
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch() {
        if !searchBar.text!.isEmpty {
            searchBar.resignFirstResponder()
            
            dataTask?.cancel()
            isLoading = true
            tableView.reloadData()
            
            hasSearched = true
            searchResults = [SearchStore]()
            
            let url = urlWithSearchString(searchString: searchBar.text!,category: segmentControl.selectedSegmentIndex)
            let session = URLSession.shared
            dataTask = session.dataTask(with: url as URL, completionHandler: { (data, response, error) in
                if let error = error as? NSError , error.code == -999 {
                    return
                } else if let responseCode = response as? HTTPURLResponse , responseCode.statusCode == 200 {
                    if let data = data, let dictionary = parseJson(data: data as NSData) {
                        self.searchResults = parseDictionary(dictionary: dictionary)
                        self.searchResults.sort(by: <)
                        
                        DispatchQueue.main.async {
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                        return
                    }
                    DispatchQueue.main.async {
                        self.hasSearched = false
                        self.isLoading = false
                        self.tableView.reloadData()
                        showNetworkError(viewController: self)
                    }
                } else {
                    print("Error \(response)")
                }
            })
            
            dataTask?.resume()
        }
    }
    
    
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

//MARK: TableViewDataSource
extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if isLoading {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
            
        } else if searchResults.count == 0 {
            
            return tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifiers.nothingFoundCell, for: indexPath)
            
        } else {
            
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
        let searchResult = searchResults[indexPath.row]
        cell.nameLabel?.text = searchResult.name
        cell.artistNameLabel?.text = String(format: "%@ (%@)", searchResult.artistName,kindForDisplay(kind: searchResult.kind))
        return cell
            
        }
    }
}

//MARK: TableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading {
            return nil
        } else {
            return indexPath as IndexPath?
        }
    }
}

