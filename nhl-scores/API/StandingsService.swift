//
//  StandingsService.swift
//  nhl-scores
//
//  Created by Alex King on 1/21/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

struct StandingsService {
    
    static func refreshStandings(_ completion: @escaping (() -> Void)) {
        guard let url = URL(string: "https://statsapi.web.nhl.com/api/v1/standings/wildCardWithLeaders?hydrate=record(overall)") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                print("No Standings data")
                return
            }
            
            let json: JSON
            do {
                json = try JSON(data: data)
            } catch {
                print(error)
                return
            }
            
            guard let divisionRecords = json["records"].array else {
                return
            }
            
            let realm = try! Realm()
            for divisionJson in divisionRecords {
                
                guard let divisionTeamsJson = divisionJson["teamRecords"].array else {
                    continue
                }
                
                for teamRecordJson in divisionTeamsJson {
                    guard let teamInfo = teamRecordJson["team"].dictionaryObject,
                        let leagueRecord = teamRecordJson["leagueRecord"].dictionaryObject else {
                            continue
                    }
                    
                    guard let teamID = teamInfo["id"] as? Int,
                        let teamWins = leagueRecord["wins"] as? Int,
                        let teamLosses = leagueRecord["losses"] as? Int,
                        let teamOTLosses = leagueRecord["ot"] as? Int else {
                            continue
                    }
                    
                    guard let goalsAgainst = teamRecordJson["goalsAgainst"].int,
                        let goalsScored = teamRecordJson["goalsScored"].int,
                        let points = teamRecordJson["points"].int,
                        let divisionRank = teamRecordJson["divisionRank"].string,
                        let conferenceRank = teamRecordJson["conferenceRank"].string,
                        let leagueRank = teamRecordJson["leagueRank"].string,
                        let wildCardRank = teamRecordJson["wildCardRank"].string,
                        let row = teamRecordJson["row"].int,
                        let gamesPlayed = teamRecordJson["gamesPlayed"].int else {
                            continue
                    }
                    
                    let clinchStatus = teamRecordJson["clinchIndicator"].string
                    
                    let streak = teamRecordJson["streak"]["streakCode"].string
                    
                    let last10JSON = teamRecordJson["records"]["overallRecords"].arrayValue
                        .compactMap({ $0.dictionary })
                        .first(where: { $0["type"]?.stringValue == "lastTen" })
                    let last10 = "\(last10JSON?["wins"]?.intValue ?? 0)-\(last10JSON?["losses"]?.intValue ?? 0)-\(last10JSON?["ot"]?.intValue ?? 0)"
                    
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
                        record.last10 = last10
                    
                        team.record = record
                    }
                }
                
            }
            
            completion()
        }
        task.resume()
    }
    
}
