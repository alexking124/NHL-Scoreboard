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
                    
                    guard let team = realm.object(ofType: Team.self, forPrimaryKey: teamID) else {
                        print("No team found")
                        continue
                    }
                    
                    let record = Record()
                    record.wins = teamWins
                    record.losses = teamLosses
                    record.otLosses = teamOTLosses
                    
                    try? realm.write {
                        team.record = record
                    }
                }
                
            }
            
        }
        task.resume()
    }
    
}
