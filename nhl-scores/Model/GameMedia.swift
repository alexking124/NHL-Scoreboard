//
//  GameMedia.swift
//  nhl-scores
//
//  Created by Alex King on 2/2/19.
//  Copyright © 2019 Alex King. All rights reserved.
//

import Foundation
import RealmSwift

class GameMedia: Object {
    
    static let mediaVersion = 1
    
    @objc dynamic var extendedHighlightsMedia: VideoMedia?
    @objc dynamic var gameRecapMedia: VideoMedia?
    
    @objc dynamic var latestFetchedMediaVersion: Int = 0
    
}
