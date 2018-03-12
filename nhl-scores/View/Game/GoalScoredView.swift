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
    var event: Event {
        let realm = try! Realm()
        return realm.object(ofType: Event.self, forPrimaryKey: self.eventID) ?? Event()
    }
    
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
    
    private lazy var goalScorerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = event.players.first { $0.playerType == "Scorer" }?.playerName
        return label
    }()
    
    private lazy var assistLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = event.players.first { $0.playerType == "Assist" }?.playerName
        return label
    }()
    
}

private extension GoalScoredView {
    
    func setupViews() {
        addSubview(contentView)
        let contentInsets = EdgeInsets(top: 4, left: 4, bottom: -4, right: -4)
        contentView.edges(to: self, insets: contentInsets)
        
        contentView.addSubview(goalScorerLabel)
        goalScorerLabel.top(to: contentView, offset: 2)
        goalScorerLabel.left(to: contentView, offset: 4)
        goalScorerLabel.right(to: contentView, offset: 4, relation: .equalOrLess)
        
        contentView.addSubview(assistLabel)
        assistLabel.topToBottom(of: goalScorerLabel)
        assistLabel.left(to: goalScorerLabel)
        assistLabel.right(to: contentView, offset: 4, relation: .equalOrLess)
        assistLabel.bottom(to: contentView, offset: -2)
    }
    
}
