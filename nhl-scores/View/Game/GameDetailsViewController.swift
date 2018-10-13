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
    
    let gameID: Int
    lazy var game: Game = {
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
    
    private lazy var scrollView = UIScrollView()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var goalsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.translatesAutoresizingMaskIntoConstraints = false
        game.gameEvents.forEach { event in
            let goalView = GoalScoredView(eventID: event.eventID)
            stackView.addArrangedSubview(goalView)
        }
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = String(format: "%@ @ %@", game.awayTeam?.abbreviation ?? "", game.homeTeam?.abbreviation ?? "")
        view.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        setupViews()
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
    
}
