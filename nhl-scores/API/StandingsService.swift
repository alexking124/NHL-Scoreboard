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
            
            guard let divisionRecords = dictionary["records"] as? [[String: Any]] else {
                return
            }
            
        }
        task.resume()
    }
    
}
