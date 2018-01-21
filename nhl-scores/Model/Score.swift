//
//  Score.swift
//  nhl-scores
//
//  Created by Alex King on 1/14/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import RealmSwift

class Score: Object {
    
    @objc dynamic var homeScore: Int = 0
    @objc dynamic var awayScore: Int = 0
    @objc dynamic var homeShots: Int = 0
    @objc dynamic var awayShots: Int = 0
    
}
