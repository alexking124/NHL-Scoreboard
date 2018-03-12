//
//  UIImageViewExt.swift
//  nhl-scores
//
//  Created by Alex King on 3/11/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit

extension UIImageView {
    public func imageFromServerURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) -> Void in
            if error != nil {
                return
            }
            DispatchQueue.main.async(execute: {
                guard let data = data else { return }
                let image = UIImage(data: data)
                self.image = image
            })
            
        }).resume()
    }
}
