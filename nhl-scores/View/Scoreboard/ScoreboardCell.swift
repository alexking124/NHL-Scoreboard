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
    @IBOutlet weak var powerPlayStatusLabel: UILabel!
    @IBOutlet weak var powerPlayTimeLabel: UILabel!
    @IBOutlet weak var awayPowerPlayLabel: UILabel!
    @IBOutlet weak var homePowerPlayLabel: UILabel!
    @IBOutlet weak var seriesStatusLabel: UILabel!
    
    private var notificationToken: NotificationToken? = nil
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
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
        
        scoreLabel.text = "error"
        
        homeRecordLabel.backgroundColor = .clear
        awayRecordLabel.backgroundColor = .clear
        
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
            scoreLabel.text = game.gameTime?.inDefaultRegion().toFormat("h:mm a")
            scoreLabel.font = scoreLabel.font.withSize(18)
            statusLabel.text = game.rawGameStatus
            homeRecordLabel.text = game.homeTeam?.record?.recordString ?? ""
            homeRecordLabel.backgroundColor = .clear
            awayRecordLabel.text = game.awayTeam?.record?.recordString ?? ""
            awayRecordLabel.backgroundColor = .clear
        } else {
            let homeScore = game.score?.homeScore ?? 0
            let awayScore = game.score?.awayScore ?? 0
            scoreLabel.text = "\(awayScore) - \(homeScore)"
            scoreLabel.font = scoreLabel.font.withSize(22)
            
            statusLabel.text = (game.gameStatus == .completed) ? game.clockString.replacingOccurrences(of: " 3rd", with: "") : game.clockString
            
            homeRecordLabel.text = "\(game.score?.homeShots ?? 0) SOG"
            awayRecordLabel.text = "\(game.score?.awayShots ?? 0) SOG"
        }
        
        awayPowerPlayLabel.isHidden = true
        homePowerPlayLabel.isHidden = true
        powerPlayStatusLabel.isHidden = true
        powerPlayTimeLabel.isHidden = true
        if game.hasPowerPlay, game.gameStatus != .completed {
            if game.homeSkaterCount < game.awaySkaterCount {
                awayPowerPlayLabel.isHidden = false
            }
            if game.awaySkaterCount < game.homeSkaterCount {
                homePowerPlayLabel.isHidden = false
            }
            let ppMinutes = game.powerPlayTimeRemaining.seconds.in(.minute) ?? 0
            let ppSeconds = String(format: "%02d", game.powerPlayTimeRemaining - (ppMinutes.minutes.in(.second) ?? 0))
            powerPlayTimeLabel.text = "\(ppMinutes):\(ppSeconds)"
            powerPlayStatusLabel.text = game.powerPlayStatus
            powerPlayTimeLabel.isHidden = false
            powerPlayStatusLabel.isHidden = false
        }
        
        homeLogo.image = game.homeTeam?.logo
        awayLogo.image = game.awayTeam?.logo
        
        seriesStatusLabel.isHidden = game.seriesStandings.isEmpty
        if !game.seriesStandings.isEmpty {
            seriesStatusLabel.text = game.seriesStandings
        }
    }
    
}
