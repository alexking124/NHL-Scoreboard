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
import ReactiveSwift

class StandingsViewController: UITableViewController {
    
    private enum WildCardSection: Int, EnumCollection {
        case unknown = -1
        case eastern = 0
        case atlantic = 1
        case metropolitan = 2
        case easternWildCard = 3
        case western = 4
        case central = 5
        case pacific = 6
        case westernWildCard = 7
        
        static var count: Int {
            return WildCardSection.allValues.count - 1
        }
        
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
            case .atlantic, .metropolitan, .central, .pacific:
                return "record.divisionRank"
            default:
                return "record.wildCardRank"
            }
        }
    }
    
    private var cellContentOffset: MutableProperty<CGFloat> = MutableProperty(0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Standings"
        
        tableView.register(StandingsCell.self, forCellReuseIdentifier: "StandingsCell")
        tableView.register(StandingsConferenceHeaderView.self, forHeaderFooterViewReuseIdentifier: "ConferenceHeader")
        tableView.register(StandingsStatsHeaderView.self, forHeaderFooterViewReuseIdentifier: "DivisionHeader")
        tableView.allowsSelection = false
        tableView.separatorInset = .zero
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
        return WildCardSection.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionType = WildCardSection(rawValue: section) ?? .unknown
        switch sectionType {
        case .eastern, .western:
            return 0 // Conference Headers
        case .unknown:
            assertionFailure("Unknown section type")
            return 0
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
        case .atlantic, .metropolitan, .central, .pacific, .easternWildCard, .westernWildCard:
            standingsCell.setTeam(team)
            standingsCell.setContentOffset(cellContentOffset.value)
            standingsCell.contentOffsetChanged = { [weak self] cell, offset in
                self?.cellContentOffset.value = offset
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
        switch sectionType {
        case .eastern, .western:
            guard let conferenceHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ConferenceHeader") as? StandingsConferenceHeaderView else { // Conference Headers
                return UIView()
            }
            conferenceHeader.conference = (section == 0) ? .eastern : .western
            return conferenceHeader
        case .atlantic, .metropolitan, .easternWildCard, .central, .pacific, .westernWildCard:
            guard let divisionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "DivisionHeader") as? StandingsStatsHeaderView else { // Division Headers
                return UIView()
            }
            divisionHeader.statsScrollViewContentOffset <~ cellContentOffset
            divisionHeader.setDivision(sectionType.title)
            return divisionHeader
        default:
            break
        }
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionType = WildCardSection(rawValue: section) ?? .unknown
        switch sectionType {
        case .eastern, .western:
            return 40 // Conference Headers
        case .atlantic, .metropolitan, .easternWildCard, .central, .pacific, .westernWildCard:
            return 20
        default:
            return 0
        }
    }
    
}
