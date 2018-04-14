//
//  ScoreboardService.swift
//  nhl-scores
//
//  Created by Alex King on 1/14/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import SwiftDate
import RealmSwift

struct ScoreboardService {
    
    static func fetchScoreboard(date: Date = Date(), completion: @escaping (() -> Void)) {
        let dateQuery = "?startDate=\(date.year)-\(date.month)-\(date.day)&endDate=\(date.year)-\(date.month)-\(date.day)"
        guard let url = URL(string: "https://statsapi.web.nhl.com/api/v1/schedule\(dateQuery)&expand=schedule.game.seriesSummary") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let dictionary = json as? [String: Any] else {
                print("Error reading json")
                return
            }
            
            guard let dates = dictionary["dates"] as? [[String: Any]],
                let currentDate = dates.first,
                let dateString = currentDate["date"] as? String,
                let currentGames = currentDate["games"] as? [[String: Any]] else {
                    print("No games found")
                    completion()
                    return
            }
            
            let realm = try! Realm()
            for gameJson in currentGames {
                
                guard let gameID = gameJson["gamePk"] as? Int,
                    let gameDateString = gameJson["gameDate"] as? String else {
                        print("Error reading json")
                        continue
                }
                
                let gameDate = DateInRegion(string: gameDateString, format: .iso8601(options: .withInternetDateTime))
                
                guard let teams = gameJson["teams"] as? [String: Any],
                let homeTeamDict = teams["home"] as? [String: Any],
                    let awayTeamDict = teams["away"] as? [String: Any] else {
                        continue
                }
                
                guard let homeScore = homeTeamDict["score"] as? Int,
                    let homeID = (homeTeamDict["team"] as? [String: Any])?["id"] as? Int,
                    let awayScore = awayTeamDict["score"] as? Int,
                    let awayID = (awayTeamDict["team"] as? [String: Any])?["id"] as? Int else {
                        continue
                }
                
                guard let statusDict = gameJson["status"] as? [String: Any],
                    let status = statusDict["detailedState"] as? String,
                    let codedGameState = statusDict["codedGameState"] as? String else {
                        print("Failed to get game state")
                        continue
                }
                
                var seriesStandings: String?
                var seriesGameNumber: Int?
                if let seriesSummaryJson = gameJson["seriesSummary"] as? [String: Any] {
                    seriesStandings = seriesSummaryJson["seriesStatusShort"] as? String
                    seriesGameNumber = seriesSummaryJson["gameNumber"] as? Int
                }
                
                let homeTeam = realm.object(ofType: Team.self, forPrimaryKey: homeID)
                let awayTeam = realm.object(ofType: Team.self, forPrimaryKey: awayID)
                
                let game: Game
                if let existingGame = realm.object(ofType: Game.self, forPrimaryKey: gameID) {
                    game = existingGame
                } else {
                    game = Game()
                    game.gameID = gameID
                    try? realm.write {
                        realm.add(game)
                    }
                }
                
                try? realm.write {
                    game.homeTeam = homeTeam
                    game.awayTeam = awayTeam
                    game.gameTime = gameDate?.absoluteDate
                    game.rawGameStatus = status
                    game.gameDay = dateString
                    game.sortStatus = GameState(rawValue: Int(codedGameState) ?? 0)?.valueForSort() ?? 0
                    
                    seriesStandings.map { game.seriesStandings = $0 }
                    seriesGameNumber.map { game.seriesGameNumber = $0 }
                    
                    let score = game.score ?? Score()
                    score.homeScore = homeScore
                    score.awayScore = awayScore
                    game.score = score
                }
            }
            
            completion()
        }
        task.resume()
    }
    
}
