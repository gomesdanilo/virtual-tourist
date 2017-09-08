//
//  FLKRCoordinatesBox.swift
//  virtual-tourist
//
//  Created by Danilo Gomes on 07/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import MapKit





/**
 A comma-delimited list of 4 values defining the Bounding Box of the area that will be searched.
 
 The 4 values represent the bottom-left corner of the box and the top-right corner, minimum_longitude, minimum_latitude, maximum_longitude, maximum_latitude.
 
 Longitude has a range of -180 to 180 , latitude of -90 to 90. Defaults to -180, -90, 180, 90 if not specified.
 
 A tag, for instance, is considered a limiting agent as are user defined min_date_taken and min_date_upload parameters — If no limiting factor is passed we return only photos added in the last 12 hours (though we may extend the limit in the future).

 
 */
struct FLKRBoundingBox {
    
    let rangeDistanceInMeters : Double = 20
    
    // x0, y0
    let minLong : Double
    let minLat : Double
    
    // x1, y1
    let maxLong : Double
    let maxLat : Double
    
    
    init (centerLongitude: Double, centerLatitude: Double, rangeInMeters: Double){
        self.init(coordinates: CLLocationCoordinate2D(latitude: centerLatitude,
                                                      longitude: centerLongitude),
                  rangeInMeters: rangeInMeters)
    }
    
    init(coordinates : CLLocationCoordinate2D, rangeInMeters : Double) {
        
        let region = MKCoordinateRegionMakeWithDistance(coordinates, rangeDistanceInMeters, rangeDistanceInMeters)
        
        self.minLat = region.center.latitude - region.span.latitudeDelta
        self.minLong = region.center.longitude - region.span.longitudeDelta
        
        self.maxLat = region.center.latitude + region.span.latitudeDelta
        self.maxLong = region.center.longitude + region.span.longitudeDelta
    }
    
    func getString() -> String {
        return "\(minLong),\(minLat),\(maxLong),\(maxLat)"
    }
}
