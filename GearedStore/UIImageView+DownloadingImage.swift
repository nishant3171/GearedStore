//
//  UIImageView+DownloadingImage.swift
//  GearedStore
//
//  Created by Nishant Punia on 15/09/16.
//  Copyright © 2016 MLBNP. All rights reserved.
//

import UIKit

extension UIImageView {
    
    func downloadingImage(url: URL) -> URLSessionDownloadTask {
        let session = URLSession.shared
        
        let downloadTask = session.downloadTask(
            with: url as URL, completionHandler: { [weak self] url, response, error in // 2
                if error == nil, let url = url,
                    // 3
                    let data = NSData(contentsOf: url), let image = UIImage(data: data as Data) { // 4
                    DispatchQueue.main.async {
                        if let strongSelf = self {
                            strongSelf.image = image
                        }
                    }
                }
            })
        downloadTask.resume()
        return downloadTask
    }
}
