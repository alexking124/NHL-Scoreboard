//
//  StandingsStatsView.swift
//  nhl-scores
//
//  Created by Alex King on 2/4/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit
import TinyConstraints
import ReactiveSwift
import Result

class StandingsStatsView: UIView {
    
    private enum Stats: String, CaseIterable {
        case points = "PTS"
        case gamesPlayed = "GP"
        case wins = "W"
        case losses = "L"
        case otLosses = "OTL"
        case row = "ROW"
        case goalDifferential = "+/-"
        case streak = "STRK"
        case last10 = "LAST 10"
        
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
                return team.record?.streak ?? ""
            case .last10:
                return team.record?.last10 ?? ""
            }
        }
        
        var itemWidth: CGFloat {
            switch self {
            case .last10:
                return 70
            default:
                return 38
            }
        }
    }
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        return scrollView
    }()
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.setContentHuggingPriority(.defaultLow, for: .vertical)
        return stackView
    }()
    
    private lazy var statLabels: [UILabel] = {
        var labels = [UILabel]()
        Stats.allCases.forEach { stat in
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 15)
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            label.setContentHuggingPriority(.defaultLow, for: .vertical)
            label.text = stat.rawValue
            label.width(stat.itemWidth)
            labels.append(label)
        }
        return labels
    }()
    
    let contentOffset: Signal<CGPoint, NoError>
    private let contentOffsetObserver: Signal<CGPoint, NoError>.Observer
    
    override init(frame: CGRect) {
        (contentOffset, contentOffsetObserver) = Signal<CGPoint, NoError>.pipe()
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        setupViews()
    }
    
    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder) hasn't been implemented")
    }
    
    func setTeam(_ team: Team) {
        assert(statLabels.count == Stats.allCases.count)
        
        zip(statLabels, Stats.allCases).forEach { (label, stat) in
            label.text = stat.value(team: team)
            if stat == .goalDifferential,
                let differential = Int(stat.value(team: team)) {
                if differential > 0 {
                    label.text = "+\(differential)"
                    label.textColor = UIColor(hexString: "0EA334")
                } else if differential < 0 {
                    label.textColor = .red
                } else {
                    label.textColor = .black
                }
            }
        }
    }
    
    func setupAsHeader() {
        statLabels.forEach {
            $0.font = UIFont.systemFont(ofSize: 12)
        }
    }
}

private extension StandingsStatsView {
    
    func setupViews() {
        addSubview(scrollView)
        scrollView.edges(to: self)
        
        scrollView.addSubview(stackView)
        stackView.edges(to: scrollView, insets: TinyEdgeInsets(top: 0, left: 0, bottom: 0, right: -5))
        stackView.height(to: scrollView)
        
        statLabels.forEach { stackView.addArrangedSubview($0) }
    }
    
}

extension StandingsStatsView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffsetObserver.send(value: scrollView.contentOffset)
    }
    
}
