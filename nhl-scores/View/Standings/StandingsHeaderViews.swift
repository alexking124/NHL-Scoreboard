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
        conferenceLabel.centerY(to: contentView)
    }
    
    private func updateConference() {
        contentView.backgroundColor = conference.color
        conferenceLabel.text = "\(conference.rawValue) Conference"
    }
}

class StandingsStatsHeaderView: UITableViewHeaderFooterView {
    
    private lazy var divisionNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var statsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let statsView = StandingsStatsView()

    var statsViewScrollOffsetChanged: (CGFloat) -> Void = { _ in }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        let colorBackground = UIView()
        colorBackground.backgroundColor = UIColor(hexString: "#bfbfbf")
        backgroundView = colorBackground
        
        contentView.addSubview(divisionNameLabel)
        divisionNameLabel.centerY(to: contentView)
        divisionNameLabel.left(to: contentView, offset: 8)
        divisionNameLabel.width(82)
        
        contentView.addSubview(statsScrollView)
        statsScrollView.leftToRight(of: divisionNameLabel)
        statsScrollView.top(to: contentView)
        statsScrollView.bottom(to: contentView)
        statsScrollView.right(to: contentView)
        statsScrollView.height(44, priority: .high)
        
        statsScrollView.addSubview(statsView)
        statsView.edges(to: statsScrollView)
        statsView.height(to: statsScrollView)
        
        statsView.setupAsHeader()
    }
    
    func setDivision(_ division: String) {
        divisionNameLabel.text = division
    }
    
}
