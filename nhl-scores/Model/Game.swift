//
//  Game.swift
//  nhl-scores
//
//  Created by Alex King on 1/19/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import RealmSwift

enum GameStatus: String {
    case scheduled = "Scheduled"
    case pregame = "Pregame"
    case live = "Live"
    case completed = "Final"
}

class Game: Object {
    
    @objc dynamic var gameID: Int = 0
    @objc dynamic var gameDay: String = ""
    @objc dynamic var gameTime: Date? = nil
    @objc dynamic var homeTeam: Team?
    @objc dynamic var awayTeam: Team?
    @objc dynamic var score: Score?
    @objc dynamic var rawGameStatus: String = ""
    
    override static func primaryKey() -> String? {
        return "gameID"
    }
    
    var gameStatus: GameStatus {
        return GameStatus(rawValue: rawGameStatus) ?? .scheduled
    }
    
}
