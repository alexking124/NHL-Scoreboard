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
    
    private lazy var statsScrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.delegate = self
        return scrollView
    }()
    
    private let statsView = StandingsStatsView()
    
    var contentOffsetChanged: (UITableViewCell, CGFloat) -> Void = { _, _ in }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        selectionStyle = .none
    }
    
    func setTeam(_ team: Team) {
        logoImageView.image = team.logo
        teamNameLabel.text = team.abbreviation
        statsView.setTeam(team)
    }
    
    func setContentOffset(_ offset: CGFloat) {
        statsScrollView.contentOffset = CGPoint(x: offset, y: 0)
    }
    
}

extension StandingsCell: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        contentOffsetChanged(self, scrollView.contentOffset.x)
    }
    
}

private extension StandingsCell {
    
    func setupViews() {
        contentView.addSubview(logoImageView)
        logoImageView.centerY(to: contentView)
        logoImageView.left(to: contentView, offset: 8)
        logoImageView.width(35)
        logoImageView.height(35)
        
        contentView.addSubview(teamNameLabel)
        teamNameLabel.centerY(to: contentView)
        teamNameLabel.leftToRight(of: logoImageView, offset: 4)
        teamNameLabel.width(60)
        
        contentView.addSubview(statsScrollView)
        statsScrollView.leftToRight(of: teamNameLabel)
        statsScrollView.top(to: contentView)
        statsScrollView.bottom(to: contentView)
        statsScrollView.right(to: contentView)
        statsScrollView.height(44, priority: .high)
        
        statsScrollView.addSubview(statsView)
        statsView.edges(to: statsScrollView)
        statsView.height(to: statsScrollView)
    }
    
}
