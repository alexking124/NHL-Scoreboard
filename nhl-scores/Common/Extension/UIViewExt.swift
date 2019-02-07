//
//  UIViewExt.swift
//  nhl-scores
//
//  Created by Alex King on 2/6/19.
//  Copyright © 2019 Alex King. All rights reserved.
//

import UIKit

extension UIView {
    
    private enum Constants {
        static let shadowOffset = CGSize(width: 0, height: 2)
        static let shadowOpacity: Float = 0.25
    }
    
    func applyCardStyle() {
        backgroundColor = .white
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = Constants.shadowOpacity
        layer.shadowOffset = Constants.shadowOffset
        layer.cornerRadius = 5
    }
    
}
