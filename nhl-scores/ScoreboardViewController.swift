//
//  ScoreboardViewController.swift
//  nhl-scores
//
//  Created by Alex King on 1/14/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import UIKit

class ScoreboardViewController: UITableViewController {
    
    let date: Date
    
    private var scores = [Score]()
    
    init(date: Date) {
        self.date = date
        super.init(nibName: nil, bundle: nil)
        tableView.register(UINib(nibName: String(describing: ScoreboardCell.self), bundle: nil) , forCellReuseIdentifier: String(describing: ScoreboardCell.self))
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Scores"
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 50
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshScores), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        refreshScores()
    }
    
}

extension ScoreboardViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return scores.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let scoreCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ScoreboardCell.self), for: indexPath) as? ScoreboardCell else {
            fatalError("Unable to dequeue ScoreboardCell")
        }
        scoreCell.bind(scores[indexPath.row])
        return scoreCell
    }
    
}

private extension ScoreboardViewController {
    
    @objc
    func refreshScores() {
        ScoreService.fetchScores(date: date) { [weak self] scores in
            self?.scores = scores
            DispatchQueue.main.async {
                self?.tableView.refreshControl?.endRefreshing()
                self?.tableView.reloadData()
            }
        }
    }
    
}
