//
//  GameSectionHeaderView.swift
//  nhl-scores
//
//  Created by Alex King on 2/2/19.
//  Copyright © 2019 Alex King. All rights reserved.
//

import Foundation
import UIKit
import TinyConstraints

class GameSectionHeaderView: UIView {
    
    init(title: String) {
        super.init(frame: .zero)
        setupViews()
        titleLabel.text = title
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20, weight: .light)
        label.textColor = UIColor(hexString: "333333")
        return label
    }()
    
    private func setupViews() {
        addSubview(titleLabel)
        let insets = TinyEdgeInsets(top: 10, left: 15, bottom: 0, right: 15)
        titleLabel.edgesToSuperview(insets: insets)
    }
}
