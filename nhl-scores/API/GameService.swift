//
//  GameService.swift
//  nhl-scores
//
//  Created by Alex King on 1/20/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import RealmSwift

struct GameService {
    
    static func updateLiveGames() {
        let realm = try! Realm()
        let liveGames = Array(realm.objects(Game.self).filter("gameDay = '\(Date().string(custom: "yyyy-MM-dd"))'")).filter { (game) -> Bool in
            if game.gameStatus == .completed {
                return false
            }
            if let gameTime = game.gameTime, gameTime < Date() {
                return true
            }
            return false
        }
        
        liveGames.forEach { (game) in
            GameService.fetchLiveStats(for: game.gameID)
        }
    }
    
    static func fetchLiveStats(for gameID: Int) {
        guard let url = URL(string: "https://statsapi.web.nhl.com/api/v1/game/\(gameID)/feed/live") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let dictionary = json as? [String: Any] else {
                    print("Error reading json")
                    return
            }
            
            guard let liveDataJson = dictionary["liveData"] as? [String: Any],
                let linescoreJson = liveDataJson["linescore"] as? [String: Any],
                let teamsJson = linescoreJson["teams"] as? [String: Any] else {
                    return
            }
            
            guard let periodString = linescoreJson["currentPeriodOrdinal"] as? String,
                let timeString = linescoreJson["currentPeriodTimeRemaining"] as? String else {
                    return
            }
            
            guard let homeTeamJson = teamsJson["home"] as? [String: Any],
                let homeScore = homeTeamJson["goals"] as? Int,
                let homeShots = homeTeamJson["shotsOnGoal"] as? Int else {
                    return
            }
            
            guard let awayTeamJson = teamsJson["away"] as? [String: Any],
                let awayScore = awayTeamJson["goals"] as? Int,
                let awayShots = awayTeamJson["shotsOnGoal"] as? Int else {
                    return
            }
            
            let realm = try! Realm()
            let game = realm.object(ofType: Game.self, forPrimaryKey: gameID)
            try? realm.write {
                game?.clockString = "\(timeString) \(periodString)"
                game?.score?.homeScore = homeScore
                game?.score?.awayScore = awayScore
                game?.score?.homeShots = homeShots
                game?.score?.awayShots = awayShots
            }
            
        }
        task.resume()
    }
    
    
}
