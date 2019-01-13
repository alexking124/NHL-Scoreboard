//
//  PenaltyView.swift
//  nhl-scores
//
//  Created by Alex King on 1/12/19.
//  Copyright © 2019 Alex King. All rights reserved.
//

import Foundation
import UIKit
import TinyConstraints
import RealmSwift

class PenaltyView: UIView {
    
    private let eventID: String
    
    private lazy var event: Event = {
        let realm = try! Realm()
        return realm.object(ofType: Event.self, forPrimaryKey: self.eventID) ?? Event()
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
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = UIEdgeInsets(top: 4,
                                               left: 4,
                                               bottom: 4,
                                               right: 4)
        return stackView
    }()
    
    private lazy var teamImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        if let teamID = NHLTeamID(rawValue: event.teamId) {
            imageView.image = UIImage.logo(for: teamID)
        }
        return imageView
    }()
    
    private lazy var penaltyDescriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.text = event.eventDescription
        return label
    }()
    
    private lazy var penaltyDetailsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        return label
    }()
    
}

private extension PenaltyView {
    
    func setupViews() {
        addSubview(teamImageView)
        teamImageView.height(35)
        teamImageView.width(35)
        teamImageView.centerYToSuperview()
        teamImageView.top(to: self, offset: 4, relation: .equalOrGreater)
        teamImageView.left(to: self, offset: 8)
        
        addSubview(penaltyDescriptionLabel)
        penaltyDescriptionLabel.leftToRight(of: teamImageView, offset: 8)
        penaltyDescriptionLabel.top(to: self, offset: 4)
        penaltyDescriptionLabel.right(to: self, offset: -8)
        
        addSubview(penaltyDetailsLabel)
        penaltyDetailsLabel.left(to: penaltyDescriptionLabel)
        penaltyDetailsLabel.topToBottom(of: penaltyDescriptionLabel, offset: 4)
        penaltyDetailsLabel.right(to: penaltyDescriptionLabel)
        penaltyDetailsLabel.bottom(to: self, offset: -4, relation: .equalOrLess)
    }
}
