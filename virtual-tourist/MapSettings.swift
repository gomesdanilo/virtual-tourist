//
//  MapSettings.swift
//  virtual-tourist
//
//  Created by Danilo Gomes on 08/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import MapKit

struct MapSettings {
    let region : MKCoordinateRegion
    
    init(region : MKCoordinateRegion) {
        self.region = region
    }
    
    init(dictionary : [String: Double]){
        
        let latitude = dictionary["center.latitude"]!
        let longitude = dictionary["center.longitude"]!
        let latitudeDelta = dictionary["span.latitudeDelta"]!
        let longitudeDelta = dictionary["span.longitudeDelta"]!
        
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpanMake(latitudeDelta, longitudeDelta)
        self.region = MKCoordinateRegionMake(coordinates, span)
    }
    
    func getDictionary() -> [String: Double]{
        return ["center.latitude": region.center.latitude,
                "center.longitude": region.center.longitude,
                "span.latitudeDelta": region.span.latitudeDelta,
                "span.longitudeDelta": region.span.longitudeDelta]
    }
}
