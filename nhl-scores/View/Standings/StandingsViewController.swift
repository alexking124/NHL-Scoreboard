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
    
    private enum WildCardSection: Int {
        case unknown = -1
        case eastern = 0
        case atlantic = 1
        case metropolitan = 2
        case easternWildCard = 3
        case western = 4
        case central = 5
        case pacific = 6
        case westernWildCard = 7
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Standings"
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "StandingsCell")
        tableView.register(StandingsConferenceHeaderView.self, forHeaderFooterViewReuseIdentifier: "ConferenceHeader")
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
            return 10 // Eastern Conference Wild Card
        case 7:
            return 9 // Western Conference Wild Card
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StandingsCell", for: indexPath)
        
        let sectionType = WildCardSection(rawValue: indexPath.section) ?? .unknown
        switch sectionType {
        case .atlantic: fallthrough
        case .metropolitan: fallthrough
        case .central: fallthrough
        case .pacific:
            cell.textLabel?.text = String("\(indexPath.section) - \(indexPath.row)")
        case .easternWildCard: fallthrough
        case .westernWildCard:
            cell.textLabel?.text = "Wild Card"
        default:
            assertionFailure("Invalid section")
            return UITableViewCell()
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = .lightGray
        switch section {
        case 0: fallthrough
        case 4:
            guard let conferenceHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ConferenceHeader") as? StandingsConferenceHeaderView else { // Conference Headers
                return UIView()
            }
            conferenceHeader.conference = (section == 0) ? .eastern : .western
            return conferenceHeader
        case 1: fallthrough
        case 2: fallthrough
        case 5: fallthrough
        case 6: fallthrough
        case 3: fallthrough
        case 7: fallthrough
        default:
            break
        }
        return headerView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: fallthrough
        case 4:
            return 40 // Conference Headers
        default:
            return 20
        }
    }
    
}
