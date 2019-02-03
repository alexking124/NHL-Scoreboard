//
//  VideoMedia.swift
//  nhl-scores
//
//  Created by Alex King on 2/2/19.
//  Copyright © 2019 Alex King. All rights reserved.
//

import Foundation
import RealmSwift

class VideoMedia: Object {
    
    @objc dynamic var thumbnailImageURL: String? = nil
    @objc dynamic var videoURL: String? = nil
    @objc dynamic var videoDuration: String = ""
    
    @objc dynamic var videoMediaVersion: Int = 0
    
    override static func primaryKey() -> String? {
        return "videoURL"
    }
    
}
