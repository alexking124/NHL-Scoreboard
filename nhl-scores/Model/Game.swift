//
//  Game.swift
//  nhl-scores
//
//  Created by Alex King on 1/19/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import RealmSwift

enum GameStatus: Int {
    case scheduled
    case pregame
    case live
    case completed
}

class Game: Object {
    
    @objc dynamic var homeTeam: Team?
    @objc dynamic var awayTeam: Team?
    @objc dynamic var rawGameStatus: Int = 0
    
    var gameStatus: GameStatus {
        return GameStatus(rawValue: rawGameStatus) ?? .scheduled
    }
    
}
