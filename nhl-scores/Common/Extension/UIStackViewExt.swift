//
//  UIStackViewExt.swift
//  nhl-scores
//
//  Created by Alex King on 12/9/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit

extension UIStackView {
    
    func clearArrangedSubviews() {
        arrangedSubviews.forEach {
            removeArrangedSubview($0)
            $0.removeFromSuperview()
        }
    }
    
}
