//
//  ScoreboardCell.swift
//  nhl-scores
//
//  Created by Alex King on 1/14/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import UIKit
import TinyConstraints
import RealmSwift
import SwiftDate

class ScoreboardCell: UITableViewCell {
    
    @IBOutlet weak var awayTeamLocationLabel: UILabel!
    @IBOutlet weak var homeTeamLocationLabel: UILabel!
    @IBOutlet weak var awayTeamNameLabel: UILabel!
    @IBOutlet weak var homeTeamNameLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var awayLogo: UIImageView!
    @IBOutlet weak var homeLogo: UIImageView!
    @IBOutlet weak var awayRecordLabel: UILabel!
    @IBOutlet weak var homeRecordLabel: UILabel!
    @IBOutlet weak var powerplayLabel: UILabel!
    
    var notificationToken: NotificationToken? = nil
    
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
        
        notificationToken?.invalidate()
        notificationToken = nil
    }

    func bindGame(_ gameID: Int) {
        guard let realm = try? Realm(),
            let game = realm.object(ofType: Game.self, forPrimaryKey: gameID) else {
                return
        }
        
        updateLabels(game: game)
        
        notificationToken = game.observe { [weak self] (changes: ObjectChange) in
            switch changes {
            case .change(_):
                self?.updateLabels(game: game)
            case .deleted:
                print("Error - game got deleted???")
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                assertionFailure("\(error)")
            }
        }
    }
}

private extension ScoreboardCell {
    
    func setupViews() {
        containerView.layer.cornerRadius = 5
        containerView.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        containerView.layer.shadowRadius = 2
        containerView.layer.shadowOpacity = 0.3
    }
    
    func updateLabels(game: Game) {
        homeTeamLocationLabel.text = game.homeTeam?.locationName
        homeTeamNameLabel.text = game.homeTeam?.teamName
        
        awayTeamLocationLabel.text = game.awayTeam?.locationName
        awayTeamNameLabel.text = game.awayTeam?.teamName
        
        if game.gameStatus == .scheduled || game.gameStatus == .pregame {
            scoreLabel.text = game.gameTime?.inDefaultRegion().string(custom: "h:mm a")
            scoreLabel.font = scoreLabel.font.withSize(18)
            statusLabel.text = game.rawGameStatus
            homeRecordLabel.text = game.homeTeam?.recordString
            homeRecordLabel.backgroundColor = UIColor.clear
            awayRecordLabel.text = game.awayTeam?.recordString
            awayRecordLabel.backgroundColor = UIColor.clear
        } else if game.gameStatus == .critical {
            if game.homeSkaterCount < 5 {
                homeRecordLabel.backgroundColor = UIColor.red
                homeRecordLabel.text = "POWERPLAY"
            }
            if game.awaySkaterCount < 5 {
                awayRecordLabel.backgroundColor = UIColor.red
                awayRecordLabel.text = "POWERPLAY"
            }
        } else {
            let homeScore = game.score?.homeScore ?? 0
            let awayScore = game.score?.awayScore ?? 0
            scoreLabel.text = "\(awayScore) - \(homeScore)"
            scoreLabel.font = scoreLabel.font.withSize(22)
            statusLabel.text = game.gameStatus == .completed ? game.rawGameStatus : game.clockString
            homeRecordLabel.text = "\(game.score?.homeShots ?? 0) SOG"
            awayRecordLabel.text = "\(game.score?.awayShots ?? 0) SOG"
        }
        
        homeLogo.image = game.homeTeam?.logo
        awayLogo.image = game.awayTeam?.logo
    }
    
}
