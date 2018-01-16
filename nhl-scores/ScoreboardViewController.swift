//
//  ScoreboardViewController.swift
//  nhl-scores
//
//  Created by Alex King on 1/14/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import UIKit

class ScoreboardViewController: UITableViewController {
    
    private var scores = [Score]()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        tableView.register(ScoreboardCell.self, forCellReuseIdentifier: String(describing: ScoreboardCell.self))
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Scores"
        tableView.tableFooterView = UIView(frame: .zero)
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshScores), for: .valueChanged)
        
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
}

private extension ScoreboardViewController {
    
    @objc
    func refreshScores() {
        ScoreService.fetchScores { [weak self] scores in
            self?.scores = scores
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
}
