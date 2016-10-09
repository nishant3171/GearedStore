//
//  Search.swift
//  GearedStore
//
//  Created by Nishant Punia on 07/10/16.
//  Copyright © 2016 MLBNP. All rights reserved.
//

import Foundation

typealias SearchComplete = (Bool) -> Void

class Search {
    var searchResults = [SearchStore]()
    var hasSearched = false
    var isLoading = false
    
    fileprivate var dataTask: URLSessionDataTask? = nil
    
    func performSearchForText(text: String, category: Int, completion: @escaping SearchComplete) {
        if !text.isEmpty {
            dataTask?.cancel()
        
            isLoading = true
            hasSearched = true
            searchResults = [SearchStore]()
        
            let url = urlWithSearchString(searchString: text, category: category)
            let session = URLSession.shared
            dataTask = session.dataTask(with: url as URL, completionHandler: { (data, response, error) in
                var success = false
                if let error = error as? NSError , error.code == -999 {
                    return
                }
                if let responseCode = response as? HTTPURLResponse , responseCode.statusCode == 200 {
                    if let data = data, let dictionary = self.parseJson(data: data as NSData) {
                        self.searchResults = self.parseDictionary(dictionary: dictionary)
                        self.searchResults.sort(by: <)
                        
                        print("Success!")
                        self.isLoading = false
                        success = true
        
                      }
                    
                    if !success {
                      print("Failure! \(response)")
                        self.hasSearched = false
                        self.isLoading = false
                    }
                    DispatchQueue.main.async {
                        completion(success)
                    }
                }
            })
                dataTask?.resume()
            
        }
    }
    
    fileprivate func urlWithSearchString(searchString: String, category: Int) -> NSURL {
        
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
    
    fileprivate func parseJson(data: NSData) -> [String: AnyObject]? {
        
        do {
            return try JSONSerialization.jsonObject(with: data as Data, options: []) as? [String: AnyObject]
        } catch {
            print("Error: \(error).")
            return nil
        }
    }
    
    fileprivate func parseDictionary(dictionary: [String: AnyObject]) -> [SearchStore] {
        
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
    
    fileprivate func parseTrack(dictionary: [String: AnyObject]) -> SearchStore {
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
    
    fileprivate func parseAudioBook(dictionary: [String: AnyObject]) -> SearchStore {
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
    
    fileprivate func parseSoftware(dictionary: [String: AnyObject]) -> SearchStore {
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
    
    fileprivate func parseEBook(dictionary: [String: AnyObject]) -> SearchStore {
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
    
}
