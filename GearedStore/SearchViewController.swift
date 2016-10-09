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
    var search = Search()
    var landscapeViewController: LandscapeViewController?
    
    
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
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscapeViewWithCoordinator(coordinator: coordinator)
        case .regular, .unspecified:
            hideLandscapeViewWithCoordinator(coordinator: coordinator)
        }
    }
    
    func showLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
        
        precondition(landscapeViewController == nil)
        landscapeViewController = storyboard?.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        
        if let controller = landscapeViewController {
            controller.search = search
            controller.view.frame = view.bounds
            controller.view.alpha = 0.0
            
            view.addSubview(controller.view)
            addChildViewController(controller)
            
            coordinator.animate(alongsideTransition: { (_) in
                controller.view.alpha = 1.0
                self.searchBar.resignFirstResponder()
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
                }, completion: { (_) in
                controller.didMove(toParentViewController: self)
            })
        }
    }
    
    func hideLandscapeViewWithCoordinator(coordinator: UIViewControllerTransitionCoordinator) {
        
        if let controller = landscapeViewController {
            controller.didMove(toParentViewController: nil)
            
            coordinator.animate(alongsideTransition: { (_) in
                controller.view.alpha = 0.0
                }, completion: { (_) in
                controller.view.removeFromSuperview()
                controller.removeFromParentViewController()
                self.landscapeViewController = nil
            })
            
        }
    }
    
    func showNetworkError(viewController: UIViewController) -> Void {
    
        let alert = UIAlertController(title: "Oops...!", message: "Failed to read from iTunes Store.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
        viewController.present(alert, animated: true, completion: nil)
    
    }

}

//MARK: SearchBar Extension
extension SearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch() {
        search.performSearchForText(text: searchBar.text!, category: segmentControl.selectedSegmentIndex, completion: { success in
            if !success {
                self.showNetworkError(viewController: self)
            }
            self.tableView.reloadData()
        })
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    
    
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

//MARK: TableViewDataSource
extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if search.isLoading {
            return 1
        } else if !search.hasSearched {
            return 0
        } else if search.searchResults.count == 0 {
        return 1
        } else {
        return search.searchResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if search.isLoading {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
            
        } else if search.searchResults.count == 0 {
            
            return tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifiers.nothingFoundCell, for: indexPath)
            
        } else {
            
        let cell = tableView.dequeueReusableCell(withIdentifier: tableViewCellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell
        let searchResult = search.searchResults[indexPath.row]
        cell.nameLabel?.text = searchResult.name
        cell.configureForSearchResult(searchResult: searchResult)
        return cell
            
        }
    }
}

//MARK: TableViewDelegate
extension SearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if search.searchResults.count == 0 || search.isLoading {
            return nil
        } else {
            return indexPath as IndexPath?
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            let detailViewController = segue.destination as! DetailViewController
            let indexPath = sender as! NSIndexPath
            let searchResult = search.searchResults[indexPath.row]
            detailViewController.searchResult = searchResult
            
        }
    }
}

