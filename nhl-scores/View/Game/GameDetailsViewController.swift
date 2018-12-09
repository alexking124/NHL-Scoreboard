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
    
    private lazy var scrollView = UIScrollView()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var goalsStackView: CardStackView = {
        let stackView = CardStackView()
        stackView.stackView.spacing = 3
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
        
        GameService.fetchLiveStats(for: gameID).start()
        
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
        
        contentStackView.addArrangedSubview(goalsStackView)
    }
    
    func bindData() {
        goalsStackView.stackView.clearArrangedSubviews()
        let goalViews = Array(game.gameEvents).map { event -> UIView in
            let isHomeTeam = event.teamId == (game.homeTeam?.rawId ?? 0)
            return GoalScoredView(eventID: event.eventID, isHomeTeam: isHomeTeam)
        }
        
        goalViews.enumerated().forEach { (index, view) in
            goalsStackView.stackView.addArrangedSubview(view)
            if index != goalViews.count - 1 {
                goalsStackView.stackView.addArrangedSubview(HorizontalLineView())
            }
        }
        
    }
    
}
