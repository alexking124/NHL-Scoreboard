//
//  GameService.swift
//  nhl-scores
//
//  Created by Alex King on 1/20/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import RealmSwift

struct GameService {
    
//    private var liveGamesNotificationToken: NotificationToken? = nil
    
    mutating func updateLiveGames() {
        let realm = try! Realm()
        
//        let liveGamesPredicate = NSPredicate(format: "gameDay = '\(Date().string(custom: "yyyy-MM-dd"))' AND gameTime < %@ AND NOT rawGameStatus = 'Final'", [Date()])
//        let liveGames = realm.objects(Game.self).filter("gameDay = '\(Date().string(custom: "yyyy-MM-dd"))' AND gameTime < \(Date()) AND NOT rawGameStatus = 'Final'")
        
        let liveGames = Array(realm.objects(Game.self).filter("gameDay = '\(Date().string(custom: "yyyy-MM-dd"))'")).filter { (game) -> Bool in
            if game.rawGameStatus == "Final" {
                return false
            }
            if let gameTime = game.gameTime, gameTime > Date(), gameTime.isInSameDayOf(date: Date()) {
                return true
            }
            
            return false
        }
        
        liveGames.forEach { (game) in
            GameService.fetchLiveStats(for: game.gameID)
        }
        
//        liveGamesNotificationToken = liveGames.observe({ (changes: RealmCollectionChange) in
//            switch changes {
//            case .error(let error):
//                // An error occurred while opening the Realm file on the background worker thread
//                fatalError("\(error)")
//            default:
//                for game in liveGames {
//                    GameService.fetchLiveStats(for: game.gameID)
//                }
//            }
//        })
    }
    
    static func fetchLiveStats(for gameID: Int) {
        guard let url = URL(string: "https://statsapi.web.nhl.com/api/v1/game/\(gameID)/feed/live") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data,
                let json = try? JSONSerialization.jsonObject(with: data, options: []),
                let dictionary = json as? [String: Any] else {
                    print("Error reading json")
                    return
            }
            
        }
        task.resume()
    }
    
    
}
