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
                return "\(team.record?.gamesPlayed ?? 0)"
            case .losses:
                return "\(team.record?.gamesPlayed ?? 0)"
            case .otLosses:
                return "\(team.record?.gamesPlayed ?? 0)"
            case .row:
                return "\(team.record?.gamesPlayed ?? 0)"
            case .goalDifferential:
                return "\(team.record?.gamesPlayed ?? 0)"
            case .streak:
                return "\(team.record?.gamesPlayed ?? 0)"
            }
        }
    }
    
    func setupWith(team: Team) {
        arrangedSubviews.forEach {
            $0.removeFromSuperview()
        }
        
        Stats.allValues.forEach { stat in
            let label = makeStatsLabel()
            label.text = stat.value(team: team)
            addArrangedSubview(label)
        }
    }
    
    private func makeStatsLabel() -> UILabel {
        let label = UILabel()
        return label
    }
    
}
