//
//  PhotoAlbumViewCell.swift
//  virtual-tourist
//
//  Created by Danilo Gomes on 08/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit

class PhotoAlbumViewCell: UICollectionViewCell {
    
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    func startLoading(){
        photo.image = nil
        activityIndicator.startAnimating()
    }
    
    func updatePicture(image : UIImage){
        photo.image = image
        activityIndicator.stopAnimating()
    }
    
    func updateError(){
        activityIndicator.stopAnimating()
        photo.image = nil
    }
}
