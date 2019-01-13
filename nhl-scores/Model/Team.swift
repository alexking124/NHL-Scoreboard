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
    @objc dynamic var abbreviation: String = ""
    
    @objc dynamic var conference: String = ""
    @objc dynamic var division: String = ""
    
    @objc dynamic var record: Record?
    
    override static func primaryKey() -> String? {
        return "rawId"
    }
    
    var id: NHLTeamID {
        return NHLTeamID(rawValue: rawId) ?? .nhl
    }
    
    var logo: UIImage? {
        return UIImage.logo(for: id)
    }
    
}
