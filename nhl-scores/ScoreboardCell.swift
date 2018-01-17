//
//  ScoreboardCell.swift
//  nhl-scores
//
//  Created by Alex King on 1/14/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import UIKit
import TinyConstraints

class ScoreboardCell: UITableViewCell {
    
//    fileprivate lazy var homeTeamLabel: UILabel = {
//        let label = UILabel()
//        label.numberOfLines = 1
//        label.font = UIFont.systemFont(ofSize: 12)
////        label.textAlignment = .right
////        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
////        label.setContentHuggingPriority(.required, for: .horizontal)
////        label.setContentHuggingPriority(.required, for: .vertical)
////        label.setContentCompressionResistancePriority(.required, for: .vertical)
//        return label
//    }()
//
//    fileprivate lazy var scoreLabel: UILabel = {
//        let label = UILabel()
//        label.setContentHuggingPriority(.required, for: .horizontal)
//        label.setContentCompressionResistancePriority(.required, for: .horizontal)
//        return label
//    }()
//
//    fileprivate lazy var awayTeamLabel: UILabel = {
//        let label = UILabel()
//        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
//        return label
//    }()
//
//    fileprivate let containerView = UIView()
    
    @IBOutlet weak var awayTeamLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var homeTeamLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        selectionStyle = .none
    }
    
    func bind(_ score: Score) {
        homeTeamLabel.text = score.homeTeam
        awayTeamLabel.text = score.awayTeam
        scoreLabel.text = score.awayScore + " - " + score.homeScore
    }
    
}

private extension ScoreboardCell {
    
    func setupViews() {
//        contentView.addSubview(containerView)
//        containerView.edges(to: contentView)
//        containerView.height(50)
//
//        containerView.addSubview(scoreLabel)
//        scoreLabel.center(in: containerView)
//
//        containerView.addSubview(homeTeamLabel)
//        homeTeamLabel.left(to: containerView, containerView.leftAnchor, offset: 10)
//        homeTeamLabel.centerY(to: containerView)
//        homeTeamLabel.rightToLeft(of: scoreLabel, offset: -10)
//
//        containerView.addSubview(awayTeamLabel)
//        awayTeamLabel.leftToRight(of: scoreLabel, offset: 10)
//        awayTeamLabel.right(to: containerView, containerView.rightAnchor, offset: -10)
//        awayTeamLabel.centerY(to: containerView)
        
        contentView.addSubview(homeTeamLabel)
//        homeTeamLabel.center(in: contentView, priority: .high)
        homeTeamLabel.top(to: contentView, offset: 12)
        homeTeamLabel.left(to: contentView, offset: 12)
        homeTeamLabel.bottom(to: contentView, offset: -12)
        homeTeamLabel.width(200)
        homeTeamLabel.height(49)
//        homeTeamLabel.edges(to: contentView)
//        homeTeamLabel.height(50)
    }
    
}
