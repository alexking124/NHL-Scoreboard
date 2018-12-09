//
//  Event.swift
//  nhl-scores
//
//  Created by Alex King on 2/10/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import RealmSwift

enum EventType: String, CaseIterable {
    case unknown = "UNKNOWN"
    case goal = "GOAL"
    case faceoof = "FACEOFF"
    case shot = "SHOT"
    case blockedShot = "BLOCKED_SHOT"
    case missedShot = "MISSED_SHOT"
    case penalty = "PENALTY"
    case giveaway = "GIVEAWAY"
    case takeaway = "TAKEAWAY"
    case hit = "HIT"
    case stop = "STOP"
}

class EventPlayer: Object {
    
    @objc dynamic var eventPlayerId: String = ""
    @objc dynamic var playerId: Int = 0
    @objc dynamic var playerName: String = ""
    @objc dynamic var playerType: String = ""
    @objc dynamic var seasonTotal: Int = 0
    
    override static func primaryKey() -> String? {
        return "eventPlayerId"
    }
    
    var imageURL: URL? {
        return URL(string: "https://nhl.bamcontent.com/images/headshots/current/168x168/\(playerId).jpg")
    }
    
}

class Event: Object {
    
    @objc dynamic var eventID: String = ""
    @objc dynamic var rawType: String = ""
    @objc dynamic var secondaryType: String = ""
    @objc dynamic var strengthCode: String = ""
    @objc dynamic var emptyNet: Bool = false
    @objc dynamic var period: Int = 0
    @objc dynamic var periodString: String = ""
    @objc dynamic var periodTimeRemaining: String = ""
    @objc dynamic var homeScore: Int = 0
    @objc dynamic var awayScore: Int = 0
    @objc dynamic var teamId: Int = -1
    @objc dynamic var penaltySeverity: String = ""
    @objc dynamic var penaltyMinutes: Int = 0
    
    let players = List<EventPlayer>()
    
    override static func primaryKey() -> String? {
        return "eventID"
    }
    
}

extension Event {
    
    var scorer: EventPlayer? {
        return players.first { $0.playerType == "Scorer" }
    }
    
}
