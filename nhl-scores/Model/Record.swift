//
//  Record.swift
//  nhl-scores
//
//  Created by Alex King on 2/3/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class Record: Object {
    
    @objc dynamic var wins: Int = 0
    @objc dynamic var losses: Int = 0
    @objc dynamic var otLosses: Int = 0
    @objc dynamic var points: Int = 0
    @objc dynamic var row: Int = 0
    @objc dynamic var gamesPlayed: Int = 0
    
    @objc dynamic var goalsFor: Int = 0
    @objc dynamic var goalsAgainst: Int = 0
    @objc dynamic var streak: String = ""
    @objc dynamic var last10: String = ""
    
    @objc dynamic var leagueRank: Int = 0
    @objc dynamic var conferenceRank: Int = 0
    @objc dynamic var divisionRank: Int = 0
    @objc dynamic var wildCardRank: Int = 0
    @objc dynamic var clinchStatus: String? = nil
    
    var recordString: String {
        return "\(wins)-\(losses)-\(otLosses)"
    }
    
}
