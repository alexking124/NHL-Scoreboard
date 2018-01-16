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
    
    fileprivate lazy var homeTeamLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    fileprivate lazy var scoreLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    fileprivate lazy var awayTeamLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ score: Score) {
        homeTeamLabel.text = score.homeTeam
        awayTeamLabel.text = score.awayTeam
        scoreLabel.text = score.homeScore + " - " + score.awayScore
        
        setNeedsLayout()
    }
    
}

private extension ScoreboardCell {
    
    func setupViews() {
        contentView.addSubview(scoreLabel)
        scoreLabel.centerY(to: contentView)
        scoreLabel.centerX(to: contentView)
        
        contentView.addSubview(homeTeamLabel)
        homeTeamLabel.left(to: contentView, offset: 10)
        homeTeamLabel.centerY(to: contentView)
        homeTeamLabel.rightToLeft(of: scoreLabel, offset: 10)
        
        contentView.addSubview(awayTeamLabel)
        awayTeamLabel.leftToRight(of: scoreLabel, offset: 10)
        awayTeamLabel.right(to: contentView, offset: 10)
        awayTeamLabel.centerY(to: contentView)
    }
    
}
