//
//  CoordinatesBoundaryBox.swift
//  virtual-tourist
//
//  Created by Danilo Gomes on 08/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import MapKit

struct CoordinatesBoundaryBox {
    let minLatitude : Double
    let maxLatitude : Double
    let minLongitude : Double
    let maxLongitude : Double
    
    init(region : MKCoordinateRegion) {
        self.minLatitude = region.center.latitude - (region.span.latitudeDelta / 2.0)
        self.maxLatitude = region.center.latitude + (region.span.latitudeDelta / 2.0)
        self.minLongitude = region.center.longitude - (region.span.longitudeDelta / 2.0)
        self.maxLongitude = region.center.longitude + (region.span.longitudeDelta / 2.0)
    }
}
