//
//  Team.swift
//  nhl-scores
//
//  Created by Alex King on 1/17/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class Team: Object {
    
    @objc dynamic var rawId: Int = 0
    @objc dynamic var teamName: String = ""
    @objc dynamic var locationName: String = ""
    
    @objc dynamic var wins: Int = 0
    @objc dynamic var losses: Int = 0
    @objc dynamic var otLosses: Int = 0
    
    override static func primaryKey() -> String? {
        return "rawId"
    }
    
    var id: NHLTeamID {
        return NHLTeamID(rawValue: rawId) ?? .nhl
    }
    
    var logo: UIImage? {
        return UIImage(named: "\(id)")
    }
    
}
