//
//  UIImageExt.swift
//  nhl-scores
//
//  Created by Alex King on 1/12/19.
//  Copyright © 2019 Alex King. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    
    static func logo(for teamID: NHLTeamID) -> UIImage? {
        return UIImage(named: "\(teamID)")
    }
}
