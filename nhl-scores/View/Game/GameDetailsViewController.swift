//
//  GameDetailsViewController.swift
//  nhl-scores
//
//  Created by Alex King on 3/10/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit
import TinyConstraints
import RealmSwift

class GameDetailsViewController: UIViewController {
    
    private let gameID: Int
    private lazy var game: Game = {
        let realm = try! Realm()
        return realm.object(ofType: Game.self, forPrimaryKey: self.gameID) ?? Game()
    }()
    
    init(gameID: Int) {
        self.gameID = gameID
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var notificationToken: NotificationToken?
    private var gameUpdateTimer: Timer?
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        return scrollView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var goalsStackContainer: CardStackView = {
        let stackView = CardStackView()
        stackView.stackView.spacing = 2
        return stackView
    }()
    
    private lazy var penaltiesStackContainer: CardStackView = {
        let stackView = CardStackView()
        stackView.stackView.spacing = 2
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = GameDetailsTitleView(homeLogo: game.homeTeam?.logo, awayLogo: game.awayTeam?.logo)
        
        view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        setupViews()
        
        notificationToken = game.observe { [weak self] (changes: ObjectChange) in
            switch changes {
            case .change(_):
                self?.bindData()
            case .deleted:
                print("Error - game got deleted???")
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                assertionFailure("\(error)")
            }
        }
        
        bindData()
    }
    
}

private extension GameDetailsViewController {
    
    func setupViews() {
        view.addSubview(scrollView)
        scrollView.edgesToSuperview()
        
        scrollView.addSubview(contentStackView)
        contentStackView.edgesToSuperview()
        contentStackView.width(to: scrollView)
        
        contentStackView.addArrangedSubview(goalsStackContainer)
        contentStackView.addArrangedSubview(penaltiesStackContainer)
    }
    
    func bindData() {
        goalsStackContainer.stackView.clearArrangedSubviews()
//        var goalViews = [UIView]()
//        var penaltyViews = [UIView]()
        let eventsArray = Array(game.gameEvents)
        let goalViews = eventsArray.filter({ $0.eventType == .goal }).map { event -> UIView in
            let isHomeTeam = event.teamId == (game.homeTeam?.rawId ?? 0)
            return GoalScoredView(eventID: event.eventID, isHomeTeam: isHomeTeam)
        }
        
        goalViews.enumerated().forEach { (index, view) in
            goalsStackContainer.stackView.addArrangedSubview(view)
            if index != goalViews.count - 1 {
                goalsStackContainer.stackView.addArrangedSubview(HorizontalLineView())
            }
        }
        
        let penaltyViews = eventsArray.filter({ $0.eventType == .penalty}).map { event -> UIView in
            return PenaltyView(eventID: event.eventID)
        }
        
        penaltiesStackContainer.stackView.clearArrangedSubviews()
        penaltyViews.enumerated().forEach { (index, penaltyView) in
            penaltiesStackContainer.stackView.addArrangedSubview(penaltyView)
            if index != penaltyViews.count - 1 {
                penaltiesStackContainer.stackView.addArrangedSubview(HorizontalLineView())
            }
        }
        
    }
    
}
