//
//  ScoreService.swift
//  nhl-scores
//
//  Created by Alex King on 1/14/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import SwiftDate

struct ScoreService {
    
    static func fetchScores(date: Date = Date(), completion: @escaping (([Score]) -> Void)) {
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
                let currentGames = currentDate["games"] as? [[String: Any]] else {
                    return
            }
            
            var scores = [Score]()
            for game in currentGames {
                guard let teams = game["teams"] as? [String: Any],
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
                
                guard let homeTeamID = NHLTeamID(rawValue: homeID),
                    let awayTeamID = NHLTeamID(rawValue: awayID) else {
                        continue
                }
                let homeTeam = Team(id: homeTeamID, name: homeName)
                let awayTeam = Team(id: awayTeamID, name: awayName)
                
                guard let statusDict = game["status"] as? [String: Any],
                    let status = statusDict["detailedState"] as? String else {
                        continue
                }
                
                let score = Score(homeTeam: homeTeam, awayTeam: awayTeam, homeScore: "\(homeScore)", awayScore: "\(awayScore)", status: status)
                scores.append(score)
            }
            
            completion(scores)
        }
        task.resume()
    }
    
}
