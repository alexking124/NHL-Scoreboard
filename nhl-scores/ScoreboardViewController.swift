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
        tableView.register(ScoreboardCell.self, forCellReuseIdentifier: "ScoreboardCell")
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        return ScoreboardCell()
    }
    
}

private extension ScoreboardViewController {
    
    @objc
    func refreshScores() {
        ScoreService.fetchScores { [weak self] scores in
            print(scores)
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
}
