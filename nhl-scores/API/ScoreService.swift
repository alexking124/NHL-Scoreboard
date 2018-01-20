//
//  ScoreService.swift
//  nhl-scores
//
//  Created by Alex King on 1/14/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import SwiftDate
import RealmSwift

struct ScoreService {
    
    static func fetchScores(date: Date = Date(), completion: @escaping (() -> Void)) {
        let dateQuery = "?startDate=\(date.year)-\(date.month)-\(date.day)&endDate=\(date.year)-\(date.month)-\(date.day)"
        guard let url = URL(string: "https://statsapi.web.nhl.com/api/v1/schedule\(dateQuery)") else {
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
            
            var games = [Game]()
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
                
                guard let homeName = (homeTeamDict["team"] as? [String: Any])?["name"] as? String,
                    let homeScore = homeTeamDict["score"] as? Int,
                    let homeID = (homeTeamDict["team"] as? [String: Any])?["id"] as? Int,
                    let awayName = (awayTeamDict["team"] as? [String: Any])?["name"] as? String,
                    let awayScore = awayTeamDict["score"] as? Int,
                    let awayID = (awayTeamDict["team"] as? [String: Any])?["id"] as? Int else {
                        continue
                }
                
                guard let statusDict = gameJson["status"] as? [String: Any],
                    let status = statusDict["detailedState"] as? String else {
                        continue
                }
                
                let score = Score()
                score.homeScore = homeScore
                score.awayScore = awayScore
                
                let homeTeam = Team()
                homeTeam.rawId = homeID
                homeTeam.teamName = homeName
                
                let awayTeam = Team()
                awayTeam.rawId = awayID
                awayTeam.teamName = awayName
                
                let game = Game()
                game.homeTeam = homeTeam
                game.awayTeam = awayTeam
                game.gameID = gameID
                game.gameTime = gameDate?.absoluteDate
                game.rawGameStatus = status
                game.gameDay = dateString
                game.score = score
                
                games.append(game)
            }
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(games, update: true)
            }
            
            completion()
        }
        task.resume()
    }
    
}
