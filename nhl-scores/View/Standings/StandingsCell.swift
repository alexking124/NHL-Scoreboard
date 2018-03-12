//
//  StandingsCell.swift
//  nhl-scores
//
//  Created by Alex King on 2/4/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit

class StandingsCell: UITableViewCell {
 
    private lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var teamNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var wildcardDividerView: UIView = {
        let view = HorizontalLineView(viewHeight: 2)
        view.backgroundColor = .darkGray
        return view
    }()
    
    private lazy var dividerView = VerticalLineView()
    
    private let statsView = StandingsStatsView()
    
    var contentOffsetChanged: (CGPoint) -> Void = { _ in }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        
        statsView.contentOffset.observeValues { [weak self] point in
            guard let `self` = self else { return }
            self.contentOffsetChanged(point)
        }
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        selectionStyle = .none
    }
    
    func setTeam(_ team: Team) {
        wildcardDividerView.removeFromSuperview()
        logoImageView.image = team.logo
        teamNameLabel.text = team.abbreviation
        statsView.setTeam(team)
        if team.record?.wildCardRank == 2 {
            addSubview(wildcardDividerView)
            wildcardDividerView.bottom(to: self)
            wildcardDividerView.left(to: self)
            wildcardDividerView.right(to: self)
        }
    }
    
    func setContentOffset(_ offset: CGPoint) {
        if !statsView.scrollView.isTracking {
            statsView.scrollView.contentOffset = offset
        }
    }
    
}

private extension StandingsCell {
    
    func setupViews() {
        contentView.addSubview(logoImageView)
        logoImageView.centerY(to: contentView)
        logoImageView.left(to: contentView, offset: 8)
        logoImageView.width(33)
        logoImageView.height(33)
        
        contentView.addSubview(teamNameLabel)
        teamNameLabel.centerY(to: contentView)
        teamNameLabel.leftToRight(of: logoImageView, offset: 4)
        teamNameLabel.width(45)
        
        contentView.addSubview(dividerView)
        dividerView.centerY(to: contentView)
        dividerView.height(to: contentView, offset: -12)
        dividerView.leftToRight(of: teamNameLabel)
        
        contentView.addSubview(statsView)
        statsView.leftToRight(of: teamNameLabel)
        statsView.top(to: contentView)
        statsView.bottom(to: contentView)
        statsView.right(to: contentView)
        statsView.height(44, priority: .defaultHigh)
    }
    
}
