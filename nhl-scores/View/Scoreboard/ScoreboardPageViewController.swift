//
//  ScoreboardPageViewController.swift
//  nhl-scores
//
//  Created by Alex King on 1/17/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import UIKit
import SwiftDate

class ScoreboardPageViewController: UIPageViewController {
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource = self
        delegate = self
        setViewControllers([ScoreboardViewController(date: Date())], direction: .forward, animated: false, completion: nil)
        setTitleFor(date: Date())
        
        let standingsButton = UIButton()
        standingsButton.setImage(UIImage(named: "Standings-Icon"), for: .normal)
        standingsButton.tintColor = .darkGray
        standingsButton.width(44)
        standingsButton.height(44)
        
        standingsButton.addTarget(self, action: #selector(standingsButtonTapped), for: .touchUpInside)
        standingsButton.tintColor = .darkGray
        standingsButton.contentEdgeInsets = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        let standingsBarButton = UIBarButtonItem(customView: standingsButton)
        navigationItem.rightBarButtonItem = standingsBarButton
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
}

extension ScoreboardPageViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let scoreboardViewController = viewController as? ScoreboardViewController else {
            return nil
        }
        let date = scoreboardViewController.date - 1.days
        return ScoreboardViewController(date: date)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let scoreboardViewController = viewController as? ScoreboardViewController else {
            return nil
        }
        let date = scoreboardViewController.date + 1.days
        return ScoreboardViewController(date: date)
    }
    
}

extension ScoreboardPageViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard let scoreboardViewController = pageViewController.viewControllers?.first as? ScoreboardViewController else {
            return
        }
        setTitleFor(date: scoreboardViewController.date)
    }
    
}

private extension ScoreboardPageViewController {
    
    @objc
    func standingsButtonTapped() {
        let standingsController = StandingsViewController()
        navigationController?.pushViewController(standingsController, animated: true)
    }
    
    func setTitleFor(date: Date) {
        title = "\(date.weekdayName(.default)), \(date.monthName(.short)). \(date.day)"
    }
    
}
