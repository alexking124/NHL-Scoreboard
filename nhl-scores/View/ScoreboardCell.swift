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
    
    @IBOutlet weak var awayTeamLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var homeTeamLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var awayLogo: UIImageView!
    @IBOutlet weak var homeLogo: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        selectionStyle = .none
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupViews()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        awayLogo.image = nil
        homeLogo.image = nil
    }
    
    func bind(_ score: Score) {
        homeTeamLabel.text = score.homeTeam.teamName
        awayTeamLabel.text = score.awayTeam.teamName
        scoreLabel.text = score.awayScore + " - " + score.homeScore
        statusLabel.text = score.status
        
        homeLogo.image = score.homeTeam.logo
        awayLogo.image = score.awayTeam.logo
    }
    
}

private extension ScoreboardCell {
    
    func setupViews() {
        containerView.layer.cornerRadius = 5
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowOpacity = 0.3
    }
    
}
