//
//  AppDelegate.swift
//  Todoey
//
//  Created by Cindy Rohr on 4/28/20.
//  Copyright © 2020 Cindy Rohr. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
 
        /* print Realm data base location */
        // print(Realm.Configuration.defaultConfiguration.fileURL)
        
        /* migration to handle if added a new item to the database */
        let config = Realm.Configuration(schemaVersion: 1, migrationBlock:{migration,oldSchemaVersion in if (oldSchemaVersion < 1){
                  /* do nothing */
            }
        })
        
        Realm.Configuration.defaultConfiguration = config
        
        do {
            _ = try Realm()
        }
        catch {
            print("Error Initializing Realm, \(error)")
        }
    
        return true
    }

}


