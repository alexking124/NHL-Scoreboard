//
//  GameDetailsTitleView.swift
//  nhl-scores
//
//  Created by Alex King on 12/8/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit
import TinyConstraints

class GameDetailsTitleView: UIView {
    
    private enum Constants {
        static let imageDimension: CGFloat = 36
    }
    
    private lazy var homeLogoImageView = AspectRatioImageView()
    private lazy var awayLogoImageView = AspectRatioImageView()
    
    private lazy var atSymbolLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.text = "@"
        return label
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [awayLogoImageView, atSymbolLabel, homeLogoImageView])
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()
    
    required init(homeLogo: UIImage?, awayLogo: UIImage?) {
        super.init(frame: .zero)
        homeLogoImageView.image = homeLogo
        awayLogoImageView.image = awayLogo
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubview(contentStackView)
        contentStackView.edgesToSuperview()
        
        homeLogoImageView.height(Constants.imageDimension)
        awayLogoImageView.height(Constants.imageDimension)
    }
    
}
