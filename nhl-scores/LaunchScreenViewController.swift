//
//  LaunchScreenViewController.swift
//  nhl-scores
//
//  Created by Alex King on 3/2/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import UIKit

class LaunchScreenViewController: UIViewController {

    static let storyboardName = "LaunchScreen"
    static let storyboardIdentifier = "LaunchImage"

    static func controllerFromStoryboard() -> LaunchScreenViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        guard let viewController = storyboard.instantiateViewController(withIdentifier: storyboardIdentifier) as? LaunchScreenViewController else {
            assertionFailure("Unable to generate LaunchImageViewController from storyboard")
            return LaunchScreenViewController()
        }
        return viewController
    }

}
