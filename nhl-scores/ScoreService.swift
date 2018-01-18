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
                let homeTeam = teams["home"] as? [String: Any],
                    let awayTeam = teams["away"] as? [String: Any] else {
                        continue
                }
                
                guard let homeName = (homeTeam["team"] as? [String: Any])?["name"] as? String,
                    let homeScore = homeTeam["score"] as? Int,
                let awayName = (awayTeam["team"] as? [String: Any])?["name"] as? String,
                    let awayScore = awayTeam["score"] as? Int else {
                        continue
                }
                
                guard let statusDict = game["status"] as? [String: Any],
                    let status = statusDict["detailedState"] as? String else {
                        continue
                }
                
                let score = Score(homeTeam: homeName, awayTeam: awayName, homeScore: "\(homeScore)", awayScore: "\(awayScore)", status: status)
                scores.append(score)
            }
            
            completion(scores)
        }
        task.resume()
    }
    
}
