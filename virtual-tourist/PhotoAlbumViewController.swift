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

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var noImagesLabel: UILabel!
    
    let server = FLKRClient.sharedInstance()
    var coordinates : CLLocationCoordinate2D?
    var pictures : [FLKRPicture]?
    var imageData : [UIImage?]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideGridAndLabel()
        retrievePictureListFromFlikr()
    }
    

    
    func retrievePictureListFromFlikr() {
        if let coordinates = coordinates {
            server.retrievePictureList(coordinates: coordinates) { (pictures, errorMessage) in
                
                guard errorMessage == nil else {
                    // Error
                    self.enableNoPicturesMode()
                    return
                }
                
                guard let pictures = pictures else {
                    // Error
                    self.enableNoPicturesMode()
                    return
                }
                
                if pictures.count > 0 {
                    self.loadScreenWithPictures(pictures)
                } else {
                    self.enableNoPicturesMode()
                }
            }
        }
    }
    
    
    
    
    func imageDataFromDisk(url : URL) ->UIImage?{
        do {
            let data = try Data(contentsOf: url)
            return UIImage(data: data)
        } catch {
            return nil
        }
    }
    
    func downloadPicture(indexPath: IndexPath){
        
        if let pics = pictures {
            let pic = pics[indexPath.row]
            if let url = pic.url {
                FLKRClient.sharedInstance().downloadPicture(url: url, completionHandler: { (url, error) in
                    
                    guard let url = url else {
                        return
                    }
                    
                    let image = self.imageDataFromDisk(url: url)
                    self.imageData![indexPath.row] = image
                    self.collectionView?.reloadItems(at: [indexPath])
                })
            }
        }
    }
    
    func imageForCell(indexPath: IndexPath) -> UIImage?{
        if let pics = imageData {
            let pic = pics[indexPath.row]
            return pic
        }
        return nil
    }
    
    
    
    // MARK: Visibility and mode code
    
    func enableNoPicturesMode(){
        // Error / No pictures
        self.pictures = []
        self.imageData = []
        self.showNoPicturesLabel()
        self.collectionView?.reloadData()
    }
    
    func loadScreenWithPictures(_ pictures : [FLKRPicture]){
        self.pictures = pictures
        self.imageData = Array<UIImage?>(repeating: nil, count: pictures.count)
        self.showPicturesGrid()
        self.collectionView?.reloadData()
    }
    
    
    func hideGridAndLabel(){
        self.collectionView.isHidden = true
        self.noImagesLabel.isHidden = true
    }
    
    func showPicturesGrid(){
        self.collectionView.isHidden = true
        self.noImagesLabel.isHidden = false
    }
    
    func showNoPicturesLabel(){
        self.collectionView.isHidden = false
        self.noImagesLabel.isHidden = true
    }
    
    
    
}

extension PhotoAlbumViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let pics = pictures {
            return pics.count
        }
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath) as! PhotoAlbumViewCell
        
        let image = imageForCell(indexPath: indexPath)
        if(image != nil){
            cell.updatePicture(image: image!)
        } else {
            cell.startLoading()
            downloadPicture(indexPath: indexPath)
        }
        
        return cell
    }
}
