//
//  ScoreboardCell.swift
//  nhl-scores
//
//  Created by Alex King on 1/14/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import UIKit
import TinyConstraints
import SwiftDate

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
    
    func bind(_ game: Game) {
        homeTeamLabel.text = game.homeTeam?.teamName
        awayTeamLabel.text = game.awayTeam?.teamName
        
        if game.gameStatus == .scheduled {
            scoreLabel.text = game.gameTime?.inDefaultRegion().string(custom: "h:mm a")
            scoreLabel.font = scoreLabel.font.withSize(18)
        } else {
            let homeScore = game.score?.homeScore ?? 0
            let awayScore = game.score?.awayScore ?? 0
            scoreLabel.text = "\(awayScore) - \(homeScore)"
            scoreLabel.font = scoreLabel.font.withSize(22)
        }
        
        statusLabel.text = game.rawGameStatus
        
        homeLogo.image = game.homeTeam?.logo
        awayLogo.image = game.awayTeam?.logo
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
