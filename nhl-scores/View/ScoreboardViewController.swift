//
//  ScoreboardViewController.swift
//  nhl-scores
//
//  Created by Alex King on 1/14/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import UIKit
import RealmSwift

class ScoreboardViewController: UITableViewController {
    
    let date: Date
    
    var notificationToken: NotificationToken? = nil
    private lazy var games: Results<Game> = {
        let realm = try! Realm()
        let games = realm.objects(Game.self).filter("gameDay = '\(date.string(custom: "yyyy-MM-dd"))'")
        return games
    }()
    
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
        
        notificationToken = games.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
        
        if games.count == 0 {
            refreshScores()
        }
    }
    
}

extension ScoreboardViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return games.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let scoreCell = tableView.dequeueReusableCell(withIdentifier: String(describing: ScoreboardCell.self), for: indexPath) as? ScoreboardCell else {
            fatalError("Unable to dequeue ScoreboardCell")
        }
        scoreCell.bind(games[indexPath.row])
        return scoreCell
    }
    
}

private extension ScoreboardViewController {
    
    @objc
    func refreshScores() {
        tableView.refreshControl?.beginRefreshing()
        ScoreService.fetchScores(date: date) { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
}
