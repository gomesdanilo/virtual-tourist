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
    
    init?(dictionary : [String: Double]){
        
        guard let latitude = dictionary["center.latitude"] else {
            return nil
        }
        guard let longitude = dictionary["center.longitude"] else {
            return nil
        }
        
        guard let longitudeDelta = dictionary["span.longitudeDelta"] else {
            return nil
        }
        
        let center = CLLocationCoordinate2D(latitude: latitude,
                                            longitude: longitude)
        let span = MKCoordinateSpanMake(0, longitudeDelta)
        self.region = MKCoordinateRegionMake(center, span)
    }
    
    func getDictionary() -> [String: Double]{
        return ["center.latitude": region.center.latitude,
                "center.longitude": region.center.longitude,
                "span.longitudeDelta": region.span.longitudeDelta]
    }
}
