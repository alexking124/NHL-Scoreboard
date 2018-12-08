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
        let statusSortDescriptor = SortDescriptor(keyPath: "sortStatus")
        let dateSortDescriptor = SortDescriptor(keyPath: "gameTime", ascending: true)
        let games = realm.objects(Game.self).filter("gameDay = '\(date.string(custom: "yyyy-MM-dd"))'").sorted(by: [statusSortDescriptor, dateSortDescriptor])
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
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.rowHeight = UITableView.automaticDimension
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
                tableView.reloadData()
            case .update(_, let deletions, let insertions, _):
                if insertions.count > 0 || deletions.count > 0 {
                    tableView.reloadData()
                }
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                assertionFailure("\(error)")
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if games.count == 0 {
            refreshScores()
        } else {
            GameService.updateFinalStats(onDate: date)
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
        scoreCell.bindGame(games[indexPath.row].gameID)
        return scoreCell
    }
    
}

extension ScoreboardViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let gameID = games[indexPath.row].gameID
        let gameDetailsViewController = GameDetailsViewController(gameID: gameID)
        self.navigationController?.pushViewController(gameDetailsViewController, animated: true)
    }
    
}

private extension ScoreboardViewController {
    
    @objc
    func refreshScores() {
        tableView.refreshControl?.beginRefreshing()
        ScoreboardService.fetchScoreboard(date: date) { [weak self] in
            guard let strongSelf = self else { return }
            GameService.updateFinalStats(onDate: strongSelf.date)
            DispatchQueue.main.async {
                strongSelf.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
}
