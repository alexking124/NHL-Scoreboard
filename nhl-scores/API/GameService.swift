//
//  GameService.swift
//  nhl-scores
//
//  Created by Alex King on 1/20/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveSwift
import Result

typealias GameUpdateSignal = Signal<Void, NoError>

enum GameUpdateStatus {
    case started(dataTask: URLSessionDataTask)
    case finished
    case cancelled
}

struct GameService {
    
    static let shared = GameService()
    
    private let gameUpdateQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    func beginUpdatingLiveGames() {
        todaysLiveGames.forEach { game in
            addGameToUpdateQueue(game.gameID)
        }
    }
    
    func stopUpdatingLiveGames() {
        gameUpdateQueue.cancelAllOperations()
    }
    
    private var todaysLiveGames: [Game] {
        let realm = try! Realm()
        let liveGames = Array(realm.objects(Game.self).filter("gameDay = '\(Date().string(custom: "yyyy-MM-dd"))'")).filter { (game) -> Bool in
            if game.gameStatus == .completed {
                return false
            }
            if let gameTime = game.gameTime, gameTime < Date() {
                return true
            }
            return false
        }
        return liveGames
    }
    
    static func updateLiveGames() -> SignalProducer<[GameUpdateStatus], NoError> {
        let realm = try! Realm()
        let liveGames = Array(realm.objects(Game.self).filter("gameDay = '\(Date().string(custom: "yyyy-MM-dd"))'")).filter { (game) -> Bool in
            if game.gameStatus == .completed {
                return false
            }
            if let gameTime = game.gameTime, gameTime < Date() {
                return true
            }
            return false
        }
        
        var updateSignals = [SignalProducer<GameUpdateStatus, NoError>]()
        liveGames.forEach { game in
            updateSignals.append(GameService.fetchLinescore(for: game.gameID))
        }
        return SignalProducer.combineLatest(updateSignals)
    }
    
    static func updateFinalStats(onDate date: Date = Date()) {
        let realm = try! Realm()
        let finalGames = Array(realm.objects(Game.self).filter("finalLiveStatsVersion < %@ AND gameDay = '\(date.string(custom: "yyyy-MM-dd"))'", Game.liveStatsVersion)).filter { (game) -> Bool in
            if game.gameStatus != .completed {
                return false
            }
            return true
        }
        
        finalGames.forEach { (game) in
            GameService.fetchLiveStats(for: game.gameID).start()
        }
    }
    
    static func fetchLinescore(for gameID: Int) -> SignalProducer<GameUpdateStatus, NoError> {
        return SignalProducer<GameUpdateStatus, NoError> {  observer, _ in
            guard let url = URL(string: "https://statsapi.web.nhl.com/api/v1/game/\(gameID)/linescore") else {
                observer.sendCompleted()
                return
            }
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []),
                    let linescoreJSON = json as? [String: Any] else {
                        print("Error reading json")
                        observer.sendCompleted()
                        return
                }
                
                guard let teamsJson = linescoreJSON["teams"] as? [String: Any] else {
                        observer.sendCompleted()
                        return
                }
                
                let periodString = linescoreJSON["currentPeriodOrdinal"] as? String ?? ""
                let timeString = linescoreJSON["currentPeriodTimeRemaining"] as? String ?? "00:00"
                
                guard let homeTeamJson = teamsJson["home"] as? [String: Any],
                    let homeScore = homeTeamJson["goals"] as? Int,
                    let homeShots = homeTeamJson["shotsOnGoal"] as? Int,
                    let homeSkaterCount = homeTeamJson["numSkaters"] as? Int else {
                        observer.sendCompleted()
                        return
                }
                
                guard let awayTeamJson = teamsJson["away"] as? [String: Any],
                    let awayScore = awayTeamJson["goals"] as? Int,
                    let awayShots = awayTeamJson["shotsOnGoal"] as? Int,
                    let awaySkaterCount = awayTeamJson["numSkaters"] as? Int else {
                        observer.sendCompleted()
                        return
                }
                
                let powerPlayString = linescoreJSON["powerPlayStrength"] as? String ?? ""
                let powerPlayInfo = linescoreJSON["powerPlayInfo"] as? [String: Any]
                let inPowerPlay = powerPlayInfo?["inSituation"] as? Bool ?? false
                let powerPlayTime = powerPlayInfo?["situationTimeRemaining"] as? Int ?? 0
                
                let realm = try! Realm()
                let game = realm.object(ofType: Game.self, forPrimaryKey: gameID)
                try? realm.write {
                    game?.clockString = "\(timeString) \(periodString)"
                    game?.score?.homeScore = homeScore
                    game?.score?.awayScore = awayScore
                    game?.score?.homeShots = homeShots
                    game?.score?.awayShots = awayShots
                    game?.homeSkaterCount = homeSkaterCount
                    game?.awaySkaterCount = awaySkaterCount
                    game?.powerPlayStatus = powerPlayString
                    game?.powerPlayTimeRemaining = powerPlayTime
                    game?.hasPowerPlay = inPowerPlay
                }
                observer.send(value: .finished)
                observer.sendCompleted()
            }
            task.resume()
            observer.send(value: .started(dataTask: task))
        }
    }
    
    static func fetchLiveStats(for gameID: Int) -> SignalProducer<GameUpdateStatus, NoError> {
        return SignalProducer<GameUpdateStatus, NoError> {  observer, _ in
            guard let url = URL(string: "https://statsapi.web.nhl.com/api/v1/game/\(gameID)/feed/live") else {
                observer.sendCompleted()
                return
            }
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []),
                    let dictionary = json as? [String: Any] else {
                        print("Error reading json")
                        observer.sendCompleted()
                        return
                }
                
                guard let liveDataJson = dictionary["liveData"] as? [String: Any],
                    let linescoreJson = liveDataJson["linescore"] as? [String: Any],
                    let playsJson = liveDataJson["plays"] as? [String: Any],
                    let teamsJson = linescoreJson["teams"] as? [String: Any] else {
                        observer.sendCompleted()
                        return
                }
                
                let periodString = linescoreJson["currentPeriodOrdinal"] as? String ?? ""
                let timeString = linescoreJson["currentPeriodTimeRemaining"] as? String ?? "00:00"
                
                guard let gameDataJson = dictionary["gameData"] as? [String: Any],
                    let statusDict = gameDataJson["status"] as? [String: Any],
                    let status = statusDict["detailedState"] as? String,
                    let codedGameState = statusDict["codedGameState"] as? String else {
                        print("Failed to get game state")
                        observer.sendCompleted()
                        return
                }
                
                guard let homeTeamJson = teamsJson["home"] as? [String: Any],
                    let homeScore = homeTeamJson["goals"] as? Int,
                    let homeShots = homeTeamJson["shotsOnGoal"] as? Int,
                    let homeSkaterCount = homeTeamJson["numSkaters"] as? Int else {
                        observer.sendCompleted()
                        return
                }
                
                guard let awayTeamJson = teamsJson["away"] as? [String: Any],
                    let awayScore = awayTeamJson["goals"] as? Int,
                    let awayShots = awayTeamJson["shotsOnGoal"] as? Int,
                    let awaySkaterCount = awayTeamJson["numSkaters"] as? Int else {
                        observer.sendCompleted()
                        return
                }
                
                let powerPlayString = linescoreJson["powerPlayStrength"] as? String ?? ""
                let powerPlayInfo = linescoreJson["powerPlayInfo"] as? [String: Any]
                let inPowerPlay = powerPlayInfo?["inSituation"] as? Bool ?? false
                let powerPlayTime = powerPlayInfo?["situationTimeRemaining"] as? Int ?? 0
                
                let events = GameService.parseEvents(json: playsJson, gameID: gameID)
                
                let realm = try! Realm()
                let game = realm.object(ofType: Game.self, forPrimaryKey: gameID)
                try? realm.write {
                    game?.rawGameStatus = status
                    if status == GameStatus.completed.rawValue {
                        game?.finalLiveStatsVersion = Game.liveStatsVersion
                    }
                    game?.sortStatus = GameState(rawValue: Int(codedGameState) ?? 0)?.valueForSort() ?? 0
                    game?.clockString = "\(timeString) \(periodString)"
                    game?.score?.homeScore = homeScore
                    game?.score?.awayScore = awayScore
                    game?.score?.homeShots = homeShots
                    game?.score?.awayShots = awayShots
                    game?.homeSkaterCount = homeSkaterCount
                    game?.awaySkaterCount = awaySkaterCount
                    game?.powerPlayStatus = powerPlayString
                    game?.powerPlayTimeRemaining = powerPlayTime
                    game?.hasPowerPlay = inPowerPlay
                    
                    game?.gameEvents.removeAll()
                    game?.gameEvents.append(objectsIn: events)
                }
                observer.send(value: .finished)
                observer.sendCompleted()
            }
            task.resume()
            observer.send(value: .started(dataTask: task))
        }
    }
    
    static func parseEvents(json eventsJson: [String: Any], gameID: Int) -> [Event] {
        var events: [Event] = []
        
        guard
            let scoringPlayIndices = eventsJson["scoringPlays"] as? [Int],
            let penaltyPlayIndices = eventsJson["penaltyPlays"] as? [Int],
            let allPlaysJson = eventsJson["allPlays"] as? [[String: Any]]
        else {
                return events
        }
        
        let realm = try! Realm()
        let allPlays = scoringPlayIndices + penaltyPlayIndices
        allPlays.forEach { eventIndex in
            let eventJson = allPlaysJson[eventIndex]
            
            guard let playersJson = eventJson["players"] as? [[String: Any]],
                let resultJson = eventJson["result"] as? [String: Any],
                let aboutJson = eventJson["about"] as? [String: Any],
                let teamJson = eventJson["team"] as? [String: Any] else {
                    return
            }
            
            let strengthJson = resultJson["strength"] as? [String: String]
            let goalsJson = aboutJson["goals"] as? [String: Int]
            
            let homeGoals = goalsJson?["home"] ?? 0
            let awayGoals = goalsJson?["away"] ?? 0
            let strengthCode = strengthJson?["code"] ?? ""
            let description = resultJson["description"] as? String ?? ""
            let penaltySeverity = resultJson["penaltySeverity"] as? String ?? ""
            let penaltyMinutes = resultJson["penaltyMinutes"] as? Int ?? 0
            
            let eventType = resultJson["eventTypeId"] as? String ?? ""
            
            let eventID = String(gameID) + String(format: "%04d", eventIndex)
            let event: Event
            if let existingEvent = realm.object(ofType: Event.self, forPrimaryKey: eventID) {
                event = existingEvent
            } else {
                event = Event()
                event.eventID = eventID
                try? realm.write {
                    realm.add(event)
                }
            }
            
            var players = [EventPlayer]()
            playersJson.forEach { playerJson in
                guard let playerDetailJson = playerJson["player"] as? [String: Any],
                    let playerId = playerDetailJson["id"] as? Int else {
                        return
                }
                
                let player = EventPlayer()
                player.playerName = playerDetailJson["fullName"] as? String ?? ""
                player.playerType = playerJson["playerType"] as? String ?? ""
                player.seasonTotal = playerJson["seasonTotal"] as? Int ?? 0
                player.eventPlayerId = eventID + String(playerId)
                player.playerId = playerId
                try? realm.write {
                    realm.add(player, update: true)
                }
                players.append(player)
            }
            
            try? realm.write {
                event.homeScore = homeGoals
                event.awayScore = awayGoals
                event.strengthCode = strengthCode
                event.rawType = eventType
                event.eventDescription = description
                event.secondaryType = resultJson["secondaryType"] as? String ?? ""
                event.emptyNet = resultJson["emptyNet"] as? Bool ?? false
                event.period = aboutJson["period"] as? Int ?? 0
                event.periodString = aboutJson["ordinalNum"] as? String ?? ""
                event.periodTimeRemaining = aboutJson["periodTime"] as? String ?? ""
                event.penaltySeverity = penaltySeverity
                event.penaltyMinutes = penaltyMinutes
                event.teamId = teamJson["id"] as? Int ?? -1
                event.players.removeAll()
                event.players.append(objectsIn: players)
            }
            
            events.append(event)
        }
        
        return events
    }
}

private extension GameService {
    
    func addGameToUpdateQueue(_ gameID: Int) {
        let updateOperation = GameUpdateOperation(gameID: gameID)
        updateOperation.completionBlock = {
            if updateOperation.isCancelled { return }
            
            if let game = try? Realm().object(ofType: Game.self, forPrimaryKey: gameID),
                game?.gameStatus == .completed {
                return
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: {
                self.addGameToUpdateQueue(gameID)
            })
        }
        gameUpdateQueue.addOperation(updateOperation)
    }
    
}

class GameUpdateOperation: AsynchronousOperation {
    
    let gameID: Int
    private let producer: SignalProducer<GameUpdateStatus, NoError>
    private var dataTask: URLSessionDataTask?
    
    init(gameID: Int) {
        self.gameID = gameID
        producer = GameService.fetchLiveStats(for: gameID)
        super.init()
    }
    
    override func execute() {
        let twoSecondTimer = SignalProducer.timer(interval: .seconds(1), on: QueueScheduler.main).startWithValues { _ in
            if self.isCancelled {
                self.dataTask?.cancel()
            }
        }
        
        producer.on(value: { status in
            if case let .started(dataTask) = status {
                self.dataTask = dataTask
            }
        }).startWithCompleted { [weak self] in
            twoSecondTimer.dispose()
            self?.finish()
        }
    }
    
}
