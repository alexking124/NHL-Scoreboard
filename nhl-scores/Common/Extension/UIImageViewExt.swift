//
//  UIImageViewExt.swift
//  nhl-scores
//
//  Created by Alex King on 3/11/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit
import Haneke

extension UIImageView {
    
    private static let cache = Cache<UIImage>(name: "playerImageCache")
    
    public func imageFromServerURL(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        UIImageView.cache.fetch(URL: url).onSuccess { [weak self] image in
            DispatchQueue.main.async {
                self?.image = image
            }
        }
    }
    
    public convenience init(contentMode: ContentMode) {
        self.init(frame: .zero)
        self.contentMode = contentMode
    }
}
