//
//  AppDelegate.swift
//  virtual-tourist
//
//  Created by Danilo Gomes on 07/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let stack = CoreDataStack()!
    var mapSettings = MapSettingsManager.loadMapSettings()
 
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        persistData()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        persistData()
    }
    
    private func persistData(){
        // Saves photo & settings data
        stack.save()
        saveMapSettings()
    }
    
    static func sharedInstance() -> AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func saveMapSettings(){
        if let mapSettings = mapSettings {
            MapSettingsManager.saveMapSettings(mapSettings)
        }
    }
}

