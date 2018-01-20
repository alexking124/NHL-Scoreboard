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
            
            var teams = [Team]()
            for teamJson in teamsArray {
                guard let teamID = teamJson["id"] as? Int,
                    let teamName = teamJson["teamName"] as? String,
                    let teamLocation = teamJson["locationName"] as? String else {
                        continue
                }
                
                let team = Team()
                team.rawId = teamID
                team.teamName = teamName
                team.locationName = teamLocation
                
                teams.append(team)
            }
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(teams, update: true)
            }
            
            completion()
        }
        task.resume()
    }
}