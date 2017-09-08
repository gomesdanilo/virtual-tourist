//
//  MapSettingsManager.swift
//  virtual-tourist
//
//  Created by Danilo Gomes on 08/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class MapSettingsManager: NSObject {

    private static let mapSettingsKey = "mapSettings"
    
    static func loadMapSettings() -> MapSettings?{
        
        let dic = UserDefaults.standard.dictionary(forKey: mapSettingsKey) as? [String: Double]
        if let dic = dic {
            return MapSettings(dictionary: dic)
        }
        return nil
    }
    
    static func saveMapSettings(_ settings : MapSettings){
        UserDefaults.standard.set(settings.getDictionary(), forKey: mapSettingsKey)
        UserDefaults.standard.synchronize()
    }
}
