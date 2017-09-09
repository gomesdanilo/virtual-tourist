//
//  Constants.swift
//  virtual-tourist
//
//  Created by Danilo Gomes on 07/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

struct Constants {

    static let reuseAnnotationIdentifier = "pin"
    
    struct Segue {
        static let ShowAlbum = "showAlbum"
    }
    
    
    // MARK: Flickr
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
        private static let API_KEY = "6e72b83e4dc79e9617c11dd9202fa0ff"
        private static let StreetAccuracy = "16"
        
        struct ParameterKeys {
            static let Latitude = "lat"
            static let Longitude = "lon"
        }
        
        static let SearchParameters = [
            "method" : "flickr.photos.search",
            "api_key" : Flickr.API_KEY,
            "safe_search" : "1",
            "extras" : "url_m",
            "format" : "json",
            "nojsoncallback" : "1",
            //"accuracy" : Flickr.StreetAccuracy,
            "sort" : "date-posted-desc",
            "per_page" : "100",
            
            "radius_units" : "km",
            "radius" : "0.300" // 300 meters from center.
        ]
        
    }
    
}
