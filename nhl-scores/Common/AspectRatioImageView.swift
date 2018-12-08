//
//  AspectRatioImageView.swift
//  nhl-scores
//
//  Created by Alex King on 12/8/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit
import TinyConstraints

class AspectRatioImageView: UIImageView {
    
    private var aspectRatioConstraint: Constraint?
    
    override var image: UIImage? {
        didSet {
            updateAspectRatio()
        }
    }
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        contentMode = .scaleAspectFit
        updateAspectRatio()
    }
    
    private func updateAspectRatio() {
        aspectRatioConstraint.flatMap { removeConstraint($0) }
        if let image = image {
            aspectRatioConstraint = width(to: self, heightAnchor, multiplier: (image.size.width / image.size.height))
        }
    }
    
}
