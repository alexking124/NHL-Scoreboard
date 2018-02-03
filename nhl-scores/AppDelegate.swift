//
//  AppDelegate.swift
//  nhl-scores
//
//  Created by Alex King on 1/14/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var gameFetchTimer: Timer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        migrateRealm()
        
        let scoreboardPageViewController = ScoreboardPageViewController()
        let mainNavigation = UINavigationController(rootViewController: scoreboardPageViewController)
        mainNavigation.navigationBar.tintColor = .darkGray
        mainNavigation.addDebugGestures()
        
        TeamService.fetchTeams {
            StandingsService.refreshStandings {
            }
        }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = mainNavigation
        window?.makeKeyAndVisible()
        
        setupGameFetchTimer()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        invalidateTimer()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        setupGameFetchTimer()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

private extension AppDelegate {
    
    func migrateRealm() {
        let currentSchemaVersion: UInt64 = 4
        let config = Realm.Configuration(schemaVersion: currentSchemaVersion,
                                         migrationBlock: { migration, oldSchemaVersion in
            if (oldSchemaVersion < currentSchemaVersion) {
                // Nothing to do!
                // Realm will automatically detect new properties and removed properties
                // And will update the schema on disk automatically
            }
        })
        
        Realm.Configuration.defaultConfiguration = config
    }
    
    func setupGameFetchTimer() {
        invalidateTimer()
        let timer = Timer(timeInterval: 15, repeats: true, block: { _ in
            GameService.updateLiveGames()
        })
        RunLoop.current.add(timer, forMode: .commonModes)
        gameFetchTimer = timer
        timer.fire()
    }
    
    func invalidateTimer() {
        gameFetchTimer?.invalidate()
        gameFetchTimer = nil
    }
    
}

