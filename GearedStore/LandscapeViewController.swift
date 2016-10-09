//
//  LandscapeViewController.swift
//  GearedStore
//
//  Created by Nishant Punia on 03/10/16.
//  Copyright © 2016 MLBNP. All rights reserved.
//

import UIKit

class LandscapeViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    //MARK: Variables
    var search: Search!
    fileprivate var firstTime = true
    fileprivate var downloadTasks = [URLSessionDownloadTask]()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        
        scrollView.removeConstraints(scrollView.constraints)
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        
        pageControl.removeConstraints(pageControl.constraints)
        pageControl.translatesAutoresizingMaskIntoConstraints = true
        pageControl.numberOfPages = 0
        
        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        scrollView.frame = view.bounds
        
        pageControl.frame = CGRect(
            x: 0,
            y: view.frame.size.height - pageControl.frame.size.height,
            width: view.frame.size.width,
            height: pageControl.frame.size.height)
        
        if firstTime {
            firstTime = false
            tileButtons(searchResults: search.searchResults)
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    private func tileButtons(searchResults: [SearchStore]) {
        var columnsPerPage = 5
        var rowsPerPage = 3
        var itemWidth: CGFloat = 96
        var itemHeight: CGFloat = 88
        var marginX: CGFloat = 0
        var marginY: CGFloat = 20
        
        let scrollViewWidth = scrollView.bounds.size.width
        
        switch scrollViewWidth {
        case 568:
            columnsPerPage = 6
            itemWidth = 94
            marginX = 2
            
        case 667:
            columnsPerPage = 7
            itemWidth = 95
            itemHeight = 98
            marginX = 1
            marginY = 29
            
        case 736:
            columnsPerPage = 8
            rowsPerPage = 4
            itemWidth = 92
            
        default:
            break
        }
        
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        
        let paddingHorz = (itemWidth - buttonWidth) / 2
        let paddingVert = (itemHeight - buttonHeight) / 2
        
        var row = 0
        var column = 0
        var x = marginX
        
        for searchResult in searchResults {
            let button = UIButton(type: .custom)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
            button.frame = CGRect(x: x + paddingHorz,
                                  y: marginY + CGFloat(row) * itemHeight + paddingVert,
                                  width: buttonWidth,
                                  height: buttonHeight)
            
            scrollView.addSubview(button)
            downloadImageForSearchResult(searchResult: searchResult, andPlaceOnButton: button)
            row += 1
            
            if row == rowsPerPage {
                row = 0
                x += itemWidth
                column += 1
            }
            
            if column == columnsPerPage {
                column = 0
                x += marginX * 2
            }
            
            let buttonsPerPage = rowsPerPage * columnsPerPage
            let numPages = 1 + (searchResults.count - 1) / buttonsPerPage
            
            scrollView.contentSize = CGSize(width: CGFloat(numPages) * scrollViewWidth, height: scrollView.frame.size.height)
            pageControl.numberOfPages = numPages
            
            print("Number of pages \(numPages).")
        }
        
    }
    
    @IBAction func pageChangedUsingPageControl(sender: UIPageControl) {
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .curveEaseInOut, animations: { 
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0)
            }, completion: nil)
    }
    
    fileprivate func downloadImageForSearchResult(searchResult: SearchStore, andPlaceOnButton button: UIButton) {
        if let url = URL(string: searchResult.artworkURL60) {
            let session = URLSession.shared
            let downloadTask = session.downloadTask(with: url) {
                [weak button] url, response, error in
                
                if error == nil, let url = url, let data = NSData(contentsOf: url), let image = UIImage(data: data as Data) {
                    DispatchQueue.main.async {
                        if let button = button {
                        button.setImage(image, for: .normal)
                        }
                    }
                }
            }
            downloadTask.resume()
            downloadTasks.append(downloadTask)
        }
    }
    
    deinit {
        print("deinit \(self).")
        for task in downloadTasks {
            task.cancel()
        }
    }

}

extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let currentPage = Int((scrollView.contentOffset.x + width/2) / width)
        pageControl.currentPage = currentPage
    }
}
