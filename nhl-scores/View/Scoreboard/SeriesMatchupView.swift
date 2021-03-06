//
//  SeriesMatchupView.swift
//  nhl-scores
//
//  Created by Alex King on 4/12/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit

class SeriesMatchupView: UIView {
    
    init() {
        super.init(frame: .zero)
        setupViews()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 1
        return stackView
    }()
    
    private lazy var gameNumberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let horizontalLine = HorizontalLineView()
    
    private lazy var seriesStandingsLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    func bind(game: Game) {
        seriesStandingsLabel.text = game.seriesStandings
        gameNumberLabel.text = "Game \(game.seriesGameNumber)"
    }
}

private extension SeriesMatchupView {
    
    func setupViews() {
        translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        stackView.edgesToSuperview()
        stackView.addArrangedSubview(gameNumberLabel)
        stackView.addArrangedSubview(horizontalLine)
        stackView.addArrangedSubview(seriesStandingsLabel)
    }
    
}
