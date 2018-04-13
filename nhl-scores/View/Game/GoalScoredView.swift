//
//  GoalScoredView.swift
//  nhl-scores
//
//  Created by Alex King on 3/4/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit
import TinyConstraints
import RealmSwift

class GoalScoredView: UIView {
    
    let eventID: String
    lazy var event: Event = {
        let realm = try! Realm()
        return realm.object(ofType: Event.self, forPrimaryKey: self.eventID) ?? Event()
    }()
    
    lazy var scorer: EventPlayer? = {
        return event.players.first { $0.playerType == "Scorer" }
    }()
    
    init(eventID: String) {
        self.eventID = eventID
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 4
        return view
    }()
    
    private lazy var playerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        if let imageURL = scorer?.imageURL {
            imageView.imageFromServerURL(imageURL.absoluteString)
        }
        return imageView
    }()
    
    private lazy var goalScorerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        let playerName = scorer?.playerName ?? ""
        let goalTotal = scorer?.seasonTotal ?? 0
        label.text = "\(playerName) (\(goalTotal))"
        return label
    }()
    
    private lazy var assistLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 11, weight: .light)
        let assistPlayers = event.players.filter {
            $0.playerType == "Assist"
        }
        let assistString = assistPlayers.map({ $0.playerName }).joined(separator: ", ")
        label.text = assistString.count == 0 ? "Unassisted" : assistString
        return label
    }()
    
    private lazy var additionalStatsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 10
        return stackView
    }()
    
    private lazy var goalTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 11, weight: .light)
        label.text = "\(event.periodTimeRemaining) \(event.periodString)"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var scoreLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 11, weight: .light)
        label.text = "\(event.awayScore) - \(event.homeScore)"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var goalTypeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 11, weight: .light)
        label.text = event.secondaryType
        label.textAlignment = .center
        return label
    }()
    
}

private extension GoalScoredView {
    
    func setupViews() {
        addSubview(contentView)
        let contentInsets = TinyEdgeInsets(top: 4, left: 4, bottom: -4, right: -4)
        contentView.edges(to: self, insets: contentInsets)
        
        contentView.addSubview(playerImageView)
        playerImageView.top(to: contentView, offset: 2)
        playerImageView.left(to: contentView, offset: 4)
        playerImageView.centerY(to: contentView)
        playerImageView.width(to: playerImageView, heightAnchor)
        playerImageView.height(45)
        
        contentView.addSubview(goalScorerLabel)
        goalScorerLabel.top(to: contentView, offset: 2)
        goalScorerLabel.leftToRight(of: playerImageView, offset: 4)
        goalScorerLabel.right(to: contentView, offset: 4, relation: .equalOrLess)
        
        contentView.addSubview(assistLabel)
        assistLabel.topToBottom(of: goalScorerLabel)
        assistLabel.left(to: goalScorerLabel)
        assistLabel.right(to: contentView, offset: 4, relation: .equalOrLess)
        
        contentView.addSubview(additionalStatsStackView)
        additionalStatsStackView.topToBottom(of: assistLabel, offset: 2, relation: .equalOrGreater)
        additionalStatsStackView.left(to: assistLabel)
        additionalStatsStackView.right(to: contentView, offset: -4)
        additionalStatsStackView.bottom(to: contentView)
        
        additionalStatsStackView.addArrangedSubview(scoreLabel)
        additionalStatsStackView.addArrangedSubview(goalTimeLabel)
        additionalStatsStackView.addArrangedSubview(goalTypeLabel)
    }
    
}
