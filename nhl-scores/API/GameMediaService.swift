//
//  GameMediaService.swift
//  nhl-scores
//
//  Created by Alex King on 2/2/19.
//  Copyright © 2019 Alex King. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveSwift
import SwiftyJSON

struct GameMediaService {
    
    static func updateMediaFor(gameID: Int) {
        guard let url = URL(string: "http://statsapi.web.nhl.com/api/v1/game/\(gameID)/content") else {
            return
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data else {
                    print("No data")
                    return
            }
            
            let json: JSON
            do {
                json = try JSON(data: data)
            } catch {
                print(error)
                return
            }
            
            let realm = try! Realm()
            
            let epgJSON = json["media"]["epg"].arrayValue
            
            var extendedHighlightsMedia: VideoMedia?
            if let videoHighlights = epgJSON.first(where: { $0["title"].stringValue == "Extended Highlights" }),
                let items = videoHighlights["items"].arrayValue.first,
                let videoURL = items["playbacks"].arrayValue.first(where: { $0["name"] == "HTTP_CLOUD_TABLET_60" })?["url"].string {
                let media = VideoMedia()
                media.thumbnailImageURL = items["image"]["cuts"]["768x432"]["src"].string
                media.videoURL = videoURL
                extendedHighlightsMedia = media
            }
            
            guard let game = realm.object(ofType: Game.self, forPrimaryKey: gameID) else {
                print("No game found")
                return
            }
            
            let media = game.media ?? GameMedia()
            try? realm.write {
                extendedHighlightsMedia.flatMap { realm.add($0, update: true) }
                media.extendedHighlightsMedia = extendedHighlightsMedia
                game.media = media
            }
            
        }
        task.resume()
    }
    
}
