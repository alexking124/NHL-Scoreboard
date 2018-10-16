//
//  StandingsService.swift
//  nhl-scores
//
//  Created by Alex King on 1/21/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import RealmSwift

struct StandingsService {
    
    static func refreshStandings(_ completion: @escaping (() -> Void)) {
        guard let url = URL(string: "https://statsapi.web.nhl.com/api/v1/standings/wildCardWithLeaders") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let dictionary = json as? [String: Any] else {
                    print("Error reading json")
                    return
            }
            
            guard let divisionRecords = dictionary["records"] as? [[String: Any]] else {
                return
            }
            
            let realm = try! Realm()
            for divisionJson in divisionRecords {
                
                guard let divisionTeamsJson = divisionJson["teamRecords"] as? [[String: Any]] else {
                    continue
                }
                
                for teamRecordJson in divisionTeamsJson {
                    guard let teamInfo = teamRecordJson["team"] as? [String: Any],
                        let leagueRecord = teamRecordJson["leagueRecord"] as? [String: Any] else {
                            continue
                    }
                    
                    guard let teamID = teamInfo["id"] as? Int,
                        let teamWins = leagueRecord["wins"] as? Int,
                        let teamLosses = leagueRecord["losses"] as? Int,
                        let teamOTLosses = leagueRecord["ot"] as? Int else {
                            continue
                    }
                    
                    guard let goalsAgainst = teamRecordJson["goalsAgainst"] as? Int,
                        let goalsScored = teamRecordJson["goalsScored"] as? Int,
                        let points = teamRecordJson["points"] as? Int,
                        let divisionRank = teamRecordJson["divisionRank"] as? String,
                        let conferenceRank = teamRecordJson["conferenceRank"] as? String,
                        let leagueRank = teamRecordJson["leagueRank"] as? String,
                        let wildCardRank = teamRecordJson["wildCardRank"] as? String,
                        let row = teamRecordJson["row"] as? Int,
                        let gamesPlayed = teamRecordJson["gamesPlayed"] as? Int else {
                            continue
                    }
                    
                    let clinchStatus: String?
                    if let clinchIndicator = teamRecordJson["clinchIndicator"] as? String {
                        clinchStatus = clinchIndicator
                    } else {
                        clinchStatus = nil
                    }
                    
                    let streakJson = teamRecordJson["streak"] as? [String: Any]
                    let streak = streakJson?["streakCode"] as? String
                    
                    guard let team = realm.object(ofType: Team.self, forPrimaryKey: teamID) else {
                        print("No team found")
                        continue
                    }
                    
                    let record = team.record ?? Record()
                    try? realm.write {
                        record.wins = teamWins
                        record.losses = teamLosses
                        record.otLosses = teamOTLosses
                        
                        record.goalsAgainst = goalsAgainst
                        record.goalsFor = goalsScored
                        record.points = points
                        record.divisionRank = Int(divisionRank) ?? 0
                        record.conferenceRank = Int(conferenceRank) ?? 0
                        record.leagueRank = Int(leagueRank) ?? 0
                        record.wildCardRank = Int(wildCardRank) ?? 0
                        record.row = row
                        record.gamesPlayed = gamesPlayed
                        record.clinchStatus = clinchStatus
                        
                        record.streak = streak ?? ""
                    
                        team.record = record
                    }
                }
                
            }
            
        }
        task.resume()
    }
    
}
