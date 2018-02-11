//
//  Event.swift
//  nhl-scores
//
//  Created by Alex King on 2/10/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import RealmSwift

enum EventType: String, EnumCollection {
    case goal = "GOAL"
    
}

class Event: Object {
    
    @objc dynamic var rawType: String = ""
    
}
