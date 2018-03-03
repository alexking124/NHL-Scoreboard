//
//  RootNavigationController.swift
//  nhl-scores
//
//  Created by Alex King on 3/2/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import Foundation
import TinyConstraints
import UIKit

class RootNavigationController: UINavigationController {

    private let launchImageViewController = LaunchScreenViewController.controllerFromStoryboard()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(launchImageViewController.view)
        launchImageViewController.view.edges(to: view)
    }

    func hideLaunchImage() {
        if view.subviews.contains(launchImageViewController.view) {
            UIView.animate(withDuration: 0.25, animations: { [weak self] in
                self?.launchImageViewController.view.alpha = 0.0
            }) { [weak self] _ in
                self?.launchImageViewController.view.removeFromSuperview()
            }
        }
    }

}
