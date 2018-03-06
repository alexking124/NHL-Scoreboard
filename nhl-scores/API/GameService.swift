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
    
    static func updateFinalStats() {
        let realm = try! Realm()
        let finalGames = Array(realm.objects(Game.self).filter("finalLiveStatsFetched = false")).filter { (game) -> Bool in
            if game.gameStatus != .completed {
                return false
            }
            return true
        }
        
        finalGames.forEach { (game) in
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
                let playsJson = liveDataJson["plays"] as? [String: Any],
                let teamsJson = linescoreJson["teams"] as? [String: Any] else {
                    return
            }
            
            guard let periodString = linescoreJson["currentPeriodOrdinal"] as? String,
                let timeString = linescoreJson["currentPeriodTimeRemaining"] as? String else {
                    return
            }
            
            guard let gameDataJson = dictionary["gameData"] as? [String: Any],
                let statusDict = gameDataJson["status"] as? [String: Any],
                let status = statusDict["detailedState"] as? String,
                let codedGameState = statusDict["codedGameState"] as? String else {
                    print("Failed to get game state")
                    return
            }
            
            guard let homeTeamJson = teamsJson["home"] as? [String: Any],
                let homeScore = homeTeamJson["goals"] as? Int,
                let homeShots = homeTeamJson["shotsOnGoal"] as? Int,
                let homeSkaterCount = homeTeamJson["numSkaters"] as? Int else {
                    return
            }
            
            guard let awayTeamJson = teamsJson["away"] as? [String: Any],
                let awayScore = awayTeamJson["goals"] as? Int,
                let awayShots = awayTeamJson["shotsOnGoal"] as? Int,
                let awaySkaterCount = awayTeamJson["numSkaters"] as? Int else {
                    return
            }
            
            guard let powerPlayString = linescoreJson["powerPlayStrength"] as? String,
                let powerPlayInfo = linescoreJson["powerPlayInfo"] as? [String: Any],
                let inPowerPlay = powerPlayInfo["inSituation"] as? Bool,
                let powerPlayTime = powerPlayInfo["situationTimeRemaining"] as? Int else {
                    return
            }
            
            let events = GameService.parseEvents(json: playsJson, gameID: gameID)
            
            let realm = try! Realm()
            let game = realm.object(ofType: Game.self, forPrimaryKey: gameID)
            try? realm.write {
                game?.rawGameStatus = status
                game?.finalLiveStatsFetched = status == GameStatus.completed.rawValue
                game?.sortStatus = GameState(rawValue: Int(codedGameState) ?? 0)?.valueForSort() ?? 0
                game?.clockString = "\(timeString) \(periodString)"
                game?.score?.homeScore = homeScore
                game?.score?.awayScore = awayScore
                game?.score?.homeShots = homeShots
                game?.score?.awayShots = awayShots
                game?.homeSkaterCount = homeSkaterCount
                game?.awaySkaterCount = awaySkaterCount
                game?.powerPlayStatus = powerPlayString
                game?.powerPlayTimeRemaining = powerPlayTime
                game?.hasPowerPlay = inPowerPlay
                
                game?.gameEvents.removeAll()
                game?.gameEvents.append(objectsIn: events)
            }
        }
        task.resume()
    }
    
    static func parseEvents(json eventsJson: [String: Any], gameID: Int) -> [Event] {
        var events: [Event] = []
        
        guard let scoringPlayIndices = eventsJson["scoringPlays"] as? [Int],
            let allPlaysJson = eventsJson["allPlays"] as? [[String: Any]] else {
                return events
        }
        
        let realm = try! Realm()
        scoringPlayIndices.forEach { scoreIndex in
            let goalJson = allPlaysJson[scoreIndex]
            
            guard let playersJson = goalJson["players"] as? [[String: Any]],
                let resultJson = goalJson["result"] as? [String: Any],
                let aboutJson = goalJson["about"] as? [String: Any] else {
                    return
            }
            
            guard let strengthJson = resultJson["strength"] as? [String: String],
                let goalsJson = aboutJson["goals"] as? [String: Int] else {
                    return
            }
            
            let eventID = String(gameID) + String(format: "%04d", scoreIndex)
            let event: Event
            if let existingEvent = realm.object(ofType: Event.self, forPrimaryKey: eventID) {
                event = existingEvent
            } else {
                event = Event()
                event.eventID = eventID
                try? realm.write {
                    realm.add(event)
                }
            }
            
            playersJson.forEach { playerJson in
                
            }
            
            events.append(event)
        }
        
        return events
    }
}
