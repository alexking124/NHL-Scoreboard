//
//  Player.swift
//  nhl-scores
//
//  Created by Alex King on 2/1/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import RealmSwift

class Player: Object {

    @objc dynamic var playerID: Int = 0
    @objc dynamic var fullName: String = ""
    @objc dynamic var number: String = ""
    @objc dynamic var team: Team?

    override static func primaryKey() -> String? {
        return "playerID"
    }

}
