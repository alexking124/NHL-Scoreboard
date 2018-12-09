//
//  GoalAttributeView.swift
//  nhl-scores
//
//  Created by Alex King on 12/9/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit
import TinyConstraints

class GoalAttributeView: UIView {
    
    enum GoalType: String {
        case powerPlay = "PPG"
        case shortHanded = "SHG"
        case emptyNet = "EN"
        
        var statusColor: UIColor {
            switch self {
            case .powerPlay:
                return #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
            case .shortHanded:
                return #colorLiteral(red: 0.1764705926, green: 0.01176470611, blue: 0.5607843399, alpha: 1)
            case .emptyNet:
                return #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            }
        }
    }
    
    private let goalType: GoalType
    
    init(type: GoalType) {
        goalType = type
        super.init(frame: .zero)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9, weight: .heavy)
        label.textColor = .white
        label.text = goalType.rawValue
        return label
    }()
    
    private func setupViews() {
        addSubview(statusLabel)
        statusLabel.centerInSuperview()
        statusLabel.left(to: self, offset: 4)
        
        height(14)
        layer.cornerRadius = 7
        layer.masksToBounds = true
        backgroundColor = goalType.statusColor
    }
    
}
