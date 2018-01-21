//
//  Game.swift
//  nhl-scores
//
//  Created by Alex King on 1/19/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import RealmSwift

enum GameState: Int {
    case scheduled = 1
    case pregame = 2
    case live = 3
    case critical = 4
    case final = 6
    case otherFinal = 7
    
    func valueForSort() -> Int {
        switch self {
        case .live: return 0
        case .critical: return 0
        case .pregame: return 1
        case .scheduled: return 1
        case .final: return 2
        case .otherFinal: return 2
        }
    }
}

enum GameStatus: String {
    case scheduled = "Scheduled"
    case pregame = "Pre-Game"
    case live = "In Progress"
    case critical = "In Progress - Critical"
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
    @objc dynamic var sortStatus: Int = 0
    
    override static func primaryKey() -> String? {
        return "gameID"
    }
    
    var gameStatus: GameStatus {
        return GameStatus(rawValue: rawGameStatus) ?? .scheduled
    }
    
}
