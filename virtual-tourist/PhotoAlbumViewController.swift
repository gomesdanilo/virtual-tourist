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
    var coordinates : CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrievePictureListFromFlikr()
    }
    

    func retrievePictureListFromFlikr() {
        if let coordinates = coordinates {
            server.retrievePictureList(coordinates: coordinates) { (pictures, errorMessage) in
                if let errorMessage = errorMessage {
                    print("Error", errorMessage)
                }
                
                if let pictures = pictures {
                    print("Pictures", pictures)
                }
            }
        }
    }
}
