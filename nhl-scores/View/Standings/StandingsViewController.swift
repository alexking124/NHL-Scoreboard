//
//  StandingsViewController.swift
//  nhl-scores
//
//  Created by Alex King on 1/27/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

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
        
        var title: String {
            switch self {
            case .atlantic: return "Atlantic"
            case .metropolitan: return "Metropolitan"
            case .central: return "Central"
            case .pacific: return "Pacific"
            case .easternWildCard, .westernWildCard: return "Wild Card"
            default:
                return "unknown"
            }
        }
        
        var teams: Results<Team> {
            let realm = try! Realm()
            return realm.objects(Team.self).filter(predicate).sorted(byKeyPath: sortKeyPath)
        }
        
        private var predicate: NSPredicate {
            switch self {
            case .atlantic:
                return NSPredicate(format: "division = 'Atlantic' AND record.divisionRank <= 3")
            case .metropolitan:
                return NSPredicate(format: "division = 'Metropolitan' AND record.divisionRank <= 3")
            case .central:
                return NSPredicate(format: "division = 'Central' AND record.divisionRank <= 3")
            case .pacific:
                return NSPredicate(format: "division = 'Pacific' AND record.divisionRank <= 3")
            case .easternWildCard:
                return NSPredicate(format: "conference = 'Eastern' AND record.wildCardRank > 0")
            case .westernWildCard:
                return NSPredicate(format: "conference = 'Western' AND record.wildCardRank > 0")
            default:
                assertionFailure("No predicate needed")
                return NSPredicate()
            }
        }
        
        private var sortKeyPath: String {
            switch self {
            case .atlantic: fallthrough
            case .metropolitan: fallthrough
            case .central: fallthrough
            case .pacific:
                return "record.divisionRank"
            default:
                return "record.wildCardRank"
            }
        }
    }
    
    private var cellContentOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Standings"
        
        tableView.register(StandingsCell.self, forCellReuseIdentifier: "StandingsCell")
        tableView.register(StandingsConferenceHeaderView.self, forHeaderFooterViewReuseIdentifier: "ConferenceHeader")
        tableView.register(StandingsStatsHeaderView.self, forHeaderFooterViewReuseIdentifier: "DivisionHeader")
        tableView.allowsSelection = false
        tableView.separatorInset = .zero
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        StandingsService.refreshStandings { [weak self] in
            self?.tableView.reloadData()
        }
    }
    
}

extension StandingsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 8
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = WildCardSection(rawValue: section) ?? .unknown
        switch sectionType {
        case .eastern: fallthrough
        case .western:
            return 0 // Conference Headers
        default:
            return sectionType.teams.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StandingsCell", for: indexPath)
        
        guard let standingsCell = cell as? StandingsCell else {
            return cell
        }
        
        let sectionType = WildCardSection(rawValue: indexPath.section) ?? .unknown
        let team = sectionType.teams[indexPath.row]
        switch sectionType {
        case .atlantic: fallthrough
        case .metropolitan: fallthrough
        case .central: fallthrough
        case .pacific: fallthrough
        case .easternWildCard: fallthrough
        case .westernWildCard:
            standingsCell.setTeam(team)
            standingsCell.setContentOffset(cellContentOffset)
            standingsCell.contentOffsetChanged = { [weak self] cell, offset in
                self?.cellContentOffset = offset
                self?.tableView.visibleCells.forEach { tableCell in
                    guard cell != tableCell,
                        let standingsCell = tableCell as? StandingsCell else {
                            return
                    }
                    standingsCell.setContentOffset(offset)
                }
            }
        default:
            assertionFailure("Invalid section")
            return UITableViewCell()
        }
        return standingsCell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionType = WildCardSection(rawValue: section) ?? .unknown
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
        case 7:
            guard let divisionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DivisionHeader") as? StandingsStatsHeaderView else { // Division Headers
                return UIView()
            }
            divisionHeader.setDivision(sectionType.title)
            return divisionHeader
        default:
            break
        }
        return UIView()
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
