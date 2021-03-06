//
//  UINavigationControllerExt.swift
//  nhl-scores
//
//  Created by Alex King on 1/20/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import UIKit
#if DEBUG
    import FLEX
#endif

extension UINavigationController {
    
    func addDebugGestures() {
        #if DEBUG
            let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showFlex))
            longPressRecognizer.minimumPressDuration = 1
            navigationBar.addGestureRecognizer(longPressRecognizer)
            
            let tripleTapGesture = UITapGestureRecognizer(target: self, action: #selector(showDebugMenu))
            tripleTapGesture.numberOfTapsRequired = 3
            navigationBar.addGestureRecognizer(tripleTapGesture)
        #endif
    }
    
    @objc
    private func showFlex() {
        #if DEBUG
            FLEXManager.shared().showExplorer()
        #endif
    }
    
    @objc
    private func showDebugMenu() {
        #if DEBUG
            let debugNavigation = UINavigationController(rootViewController: DebugMenuViewController())
            present(debugNavigation, animated: true, completion: nil)
        #endif
    }
    
}
