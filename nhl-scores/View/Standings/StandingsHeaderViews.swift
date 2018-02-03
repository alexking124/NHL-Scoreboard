//
//  StandingsHeaderViews.swift
//  nhl-scores
//
//  Created by Alex King on 2/3/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit

enum Conference: String {
    case western = "Western"
    case eastern = "Eastern"
    
    var color: UIColor {
        switch self {
        case .western:
            return UIColor(hexString: "042d6a")
        case .eastern:
            return UIColor(hexString: "b50024")
        }
    }
}

class StandingsConferenceHeaderView: UITableViewHeaderFooterView {
    
    var conference: Conference = .western {
        didSet {
            updateConference()
        }
    }
    
    private lazy var conferenceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 18)
        label.font = UIFont.systemFont(ofSize: 20, weight: .thin)
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        conferenceLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(conferenceLabel)
        conferenceLabel.left(to: contentView, offset: 12)
//        conferenceLabel.bottom(to: contentView, offset: -4)
        conferenceLabel.centerY(to: contentView)
    }
    
    private func updateConference() {
        contentView.backgroundColor = conference.color
        conferenceLabel.text = "\(conference.rawValue) Conference"
    }
}
