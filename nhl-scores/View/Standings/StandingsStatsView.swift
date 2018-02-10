//
//  StandingsStatsView.swift
//  nhl-scores
//
//  Created by Alex King on 2/4/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit

class StandingsStatsView: UIStackView {
    
    private enum Constants {
        static let itemWidth: CGFloat = 38
    }
    
    private enum Stats: String, EnumCollection {
        case points = "PTS"
        case gamesPlayed = "GP"
        case wins = "W"
        case losses = "L"
        case otLosses = "OTL"
        case row = "ROW"
        case goalDifferential = "+/-"
        case streak = "STRK"
        
        func value(team: Team) -> String {
            switch self {
            case .points:
                return "\(team.record?.points ?? 0)"
            case .gamesPlayed:
                return "\(team.record?.gamesPlayed ?? 0)"
            case .wins:
                return "\(team.record?.wins ?? 0)"
            case .losses:
                return "\(team.record?.losses ?? 0)"
            case .otLosses:
                return "\(team.record?.otLosses ?? 0)"
            case .row:
                return "\(team.record?.row ?? 0)"
            case .goalDifferential:
                return "\((team.record?.goalsFor ?? 0) - (team.record?.goalsAgainst ?? 0))"
            case .streak:
                return "\(team.record?.streak ?? "")"
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        axis = .horizontal
        alignment = .center
        distribution = .equalCentering
        translatesAutoresizingMaskIntoConstraints = false
        setContentHuggingPriority(.defaultLow, for: .vertical)
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder) hasn't been implemented")
    }
    
    func setTeam(_ team: Team) {
        arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        Stats.allValues.forEach { stat in
            let label = makeStatsLabel()
            label.text = stat.value(team: team)
            label.width(Constants.itemWidth)
            addArrangedSubview(label)
        }
    }
    
    func setupAsHeader() {
        arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        Stats.allValues.forEach { stat in
            let label = makeStatsLabel()
            label.font = UIFont.systemFont(ofSize: 12)
            label.text = stat.rawValue
            label.width(Constants.itemWidth)
            addArrangedSubview(label)
        }
    }
    
    private func makeStatsLabel() -> UILabel {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.setContentHuggingPriority(.defaultLow, for: .vertical)
        return label
    }
    
}
