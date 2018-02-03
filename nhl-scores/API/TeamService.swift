//
//  TeamService.swift
//  nhl-scores
//
//  Created by Alex King on 1/19/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import RealmSwift

struct TeamService {
    
    static func fetchTeams(_ completion: @escaping (() -> Void)) {
        guard let url = URL(string: "https://statsapi.web.nhl.com/api/v1/teams") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let dictionary = json as? [String: Any] else {
                    print("Error reading json")
                    return
            }
            
            guard let teamsArray = dictionary["teams"] as? [[String: Any]] else {
                    print("No teams found")
                    completion()
                    return
            }
            
            let realm = try! Realm()
            for teamJson in teamsArray {
                guard let teamID = teamJson["id"] as? Int,
                    let teamName = teamJson["teamName"] as? String,
                    let teamLocation = teamJson["locationName"] as? String,
                    let abbreviation = teamJson["abbreviation"] as? String else {
                        continue
                }
                
                guard let divisionJson = teamJson["division"] as? [String: Any],
                    let division = divisionJson["name"] as? String,
                    let conferenceJson = teamJson["conference"] as? [String: Any],
                    let conference = conferenceJson["name"] as? String else {
                        continue
                }
                
                let team: Team
                if let existingTeam = realm.object(ofType: Team.self, forPrimaryKey: teamID) {
                    team = existingTeam
                } else {
                    team = Team()
                    team.rawId = teamID
                    try? realm.write {
                        realm.add(team)
                    }
                }
                
                try? realm.write {
                    team.teamName = teamName
                    team.locationName = teamLocation
                    team.abbreviation = abbreviation
                    
                    team.division = division
                    team.conference = conference
                }
            }
            
            completion()
        }
        task.resume()
    }
}
