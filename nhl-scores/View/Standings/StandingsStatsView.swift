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
    
    private enum Stats: EnumCollection {
        case points
        case gamesPlayed
        case wins
        case losses
        case otLosses
        case row
        case goalDifferential
        case streak
        
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
        spacing = 4
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
            label.width(35)
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
