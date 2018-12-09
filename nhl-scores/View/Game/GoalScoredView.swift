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
    
    private let eventID: String
    private let isHomeTeam: Bool
    
    private lazy var event: Event = {
        let realm = try! Realm()
        return realm.object(ofType: Event.self, forPrimaryKey: self.eventID) ?? Event()
    }()
    
    private lazy var scorer: EventPlayer? = {
        return event.players.first { $0.playerType == "Scorer" }
    }()
    
    init(eventID: String, isHomeTeam: Bool) {
        self.eventID = eventID
        self.isHomeTeam = isHomeTeam
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 2,
                                               left: 4,
                                               bottom: 2,
                                               right: 4)
        return stackView
    }()
    
    private lazy var goalStatsView = GoalStatsView(eventID: eventID, isHomeTeam: isHomeTeam)
    
    private lazy var playerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        if let imageURL = scorer?.imageURL {
            imageView.imageFromServerURL(imageURL.absoluteString)
        }
        return imageView
    }()
    
}

private extension GoalScoredView {
    
    func setupViews() {
        addSubview(contentStackView)
        contentStackView.edgesToSuperview()
        
//        if isHomeTeam {
//            contentStackView.addArrangedSubview(goalStatsView)
//            contentStackView.addArrangedSubview(playerImageView)
//        } else {
            contentStackView.addArrangedSubview(playerImageView)
            contentStackView.addArrangedSubview(goalStatsView)
//        }
        
        playerImageView.height(45)
        playerImageView.width(to: playerImageView, heightAnchor)
    }
    
}

// MARK: - GoalStatsView

private class GoalStatsView: UIView {
    
    private let eventID: String
    private let isHomeTeam: Bool
    
    init(eventID: String, isHomeTeam: Bool) {
        self.eventID = eventID
        self.isHomeTeam = isHomeTeam
        super.init(frame: .zero)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var event: Event = {
        let realm = try! Realm()
        return realm.object(ofType: Event.self, forPrimaryKey: self.eventID) ?? Event()
    }()
    
    private lazy var goalScorerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        let playerName = event.scorer?.playerName ?? ""
        let goalTotal = event.scorer?.seasonTotal ?? 0
        label.text = "\(playerName) (\(goalTotal))"
        return label
    }()
    
    private lazy var attributesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.spacing = 5
        if let attribute = GoalAttributeView.GoalType(rawValue: event.strengthCode) {
            stackView.addArrangedSubview(GoalAttributeView(type: attribute))
        }
        if event.emptyNet {
            stackView.addArrangedSubview(GoalAttributeView(type: .emptyNet))
        }
        return stackView
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
    
    private func setupViews() {
        addSubview(goalScorerLabel)
        goalScorerLabel.top(to: self)
        goalScorerLabel.left(to: self)
        
        addSubview(attributesStackView)
        attributesStackView.centerY(to: goalScorerLabel)
        attributesStackView.leftToRight(of: goalScorerLabel, offset: 4)
        attributesStackView.right(to: self, relation: .equalOrLess)
        
        addSubview(assistLabel)
        assistLabel.topToBottom(of: goalScorerLabel)
        assistLabel.left(to: self)
        assistLabel.right(to: self, relation: .equalOrLess)
        
        addSubview(additionalStatsStackView)
        additionalStatsStackView.topToBottom(of: assistLabel, offset: 2, relation: .equalOrGreater)
        additionalStatsStackView.edgesToSuperview(excluding: [.top])
        
        additionalStatsStackView.addArrangedSubview(scoreLabel)
        additionalStatsStackView.addArrangedSubview(goalTimeLabel)
        additionalStatsStackView.addArrangedSubview(goalTypeLabel)
    }
    
}
