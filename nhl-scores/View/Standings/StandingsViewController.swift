//
//  StandingsViewController.swift
//  nhl-scores
//
//  Created by Alex King on 1/27/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit

class StandingsViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
}

extension StandingsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: fallthrough
        case 4:
            return 0 // Conference Headers
        case 1: fallthrough
        case 2: fallthrough
        case 5: fallthrough
        case 6:
            return 3 // Division Leaders
        case 3:
            return 8 // Eastern Conference Wild Card
        case 7:
            return 7 // Western Conference Wild Card
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = String("\(indexPath.section) - \(indexPath.row)")
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .blue
        switch section {
        case 0: fallthrough
        case 4:
            headerView.height(40) // Conference Headers
        case 1: fallthrough
        case 2: fallthrough
        case 5: fallthrough
        case 6:
            headerView.height(18) // Division Leaders
        case 3:
            headerView.height(18) // Eastern Conference Wild Card
        case 7:
            headerView.height(18) // Western Conference Wild Card
        default:
            headerView.height(0)
        }
        return headerView
    }
    
}
