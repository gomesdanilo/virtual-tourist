//
//  PhotoAlbumViewController.swift
//  virtual-tourist
//
//  Created by Danilo Gomes on 07/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController: UIViewController {

    let server = FLKRClient.sharedInstance()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrievePictureListFromFlikr()
    }

    func retrievePictureListFromFlikr() {
        
        // Temple bar
        
        
        let coordinatesTempleBar = CLLocationCoordinate2D(latitude: -6.267458, longitude: 53.344932)
        let range : Double = 20
        let coordinates = FLKRBoundingBox(coordinates: coordinatesTempleBar, rangeInMeters: range)
        server.retrievePictureList(coordinatesBox: coordinates)
    }
    

}
