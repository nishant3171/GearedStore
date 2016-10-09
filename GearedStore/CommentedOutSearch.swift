//
//  CommentedOutSearch.swift
//  GearedStore
//
//  Created by Nishant Punia on 07/10/16.
//  Copyright © 2016 MLBNP. All rights reserved.
//

import Foundation

//if !text.isEmpty {
//    dataTask?.cancel()

//    isLoading = true
//    hasSearched = true
//    searchResults = [SearchStore]()
//    
//    let url = urlWithSearchString(searchString: searchBar.text!,category: segmentControl.selectedSegmentIndex)
//    let session = URLSession.shared
//    dataTask = session.dataTask(with: url as URL, completionHandler: { (data, response, error) in
//        if let error = error as? NSError , error.code == -999 {
//            return
//        }
//if let responseCode = response as? HTTPURLResponse , responseCode.statusCode == 200 {
//            if let data = data, let dictionary = self.parseJson(data: data as NSData) {
//                self.searchResults = self.parseDictionary(dictionary: dictionary)
//                self.searchResults.sort(by: <)
//                print("Success!")
//                self.isLoading = false
//                return
//
//              }
//              print("Failure! \(response)")
//                self.hasSearched = false
//                self.isLoading = false
//              })
//              dataTask?.resume()
//            }
//  }
