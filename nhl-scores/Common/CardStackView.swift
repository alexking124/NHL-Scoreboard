//
//  CardStackView.swift
//  nhl-scores
//
//  Created by Alex King on 12/9/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit
import TinyConstraints

class CardStackView: UIView {
    
    private enum Constants {
        static let shadowOffset = CGSize(width: 0, height: 2)
        static let shadowOpacity: Float = 0.25
        static let contentInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    }
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.applyCardStyle()
        return view
    }()
    
    public lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        return stackView
    }()
    
    private func setupViews() {
        addSubview(containerView)
        containerView.edgesToSuperview(insets: Constants.contentInsets)
        
        containerView.addSubview(stackView)
        stackView.edgesToSuperview()
    }
    
}
