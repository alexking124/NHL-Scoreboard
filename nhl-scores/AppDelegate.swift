//
//  AppDelegate.swift
//  nhl-scores
//
//  Created by Alex King on 1/14/18.
//  Copyright © 2018 Alex King. All rights reserved.
//

import UIKit
import RealmSwift
import FirebaseAnalytics
import Fabric
import Crashlytics

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        Fabric.with([Crashlytics.self])
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(300)
        
        migrateRealm()
        
        let scoreboardPageViewController = ScoreboardPageViewController()
        let rootNavigation = RootNavigationController(rootViewController: scoreboardPageViewController)
        rootNavigation.navigationBar.tintColor = .darkGray
        rootNavigation.addDebugGestures()

        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = rootNavigation
        self.window?.makeKeyAndVisible()

        let teamsExistAction: (() -> Void) = {
            rootNavigation.hideLaunchImage()
            StandingsService.refreshStandings {
            }
        }

        let realm = try! Realm()
        let teamsFetched = realm.objects(Team.self).count != 0

        if !teamsFetched {
            TeamService.fetchTeams {
                DispatchQueue.main.async {
                    teamsExistAction()
                }
            }
        } else {
            teamsExistAction()
        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        GameService.shared.stopUpdatingLiveGames()
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
        GameService.shared.beginUpdatingLiveGames()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        GameService.updateLiveGames().startWithValues({ statuses in
            print(statuses)
            if statuses.isEmpty {
                completionHandler(.noData)
            } else {
                completionHandler(.newData)
            }
        })
    }

}

private extension AppDelegate {
    
    func migrateRealm() {
        let currentSchemaVersion: UInt64 = 12
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
    
}

