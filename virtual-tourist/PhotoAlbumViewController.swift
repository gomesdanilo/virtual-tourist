//
//  PhotoAlbumViewController.swift
//  virtual-tourist
//
//  Created by Danilo Gomes on 07/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: UIViewController {

    // MARK: UI
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    // MARK: Data
    let server = FLKRClient.sharedInstance()
    var pin : Pin?
    var coordinates : CLLocationCoordinate2D?
    var region : MKCoordinateRegion?
    let coredataStack = AppDelegate.sharedInstance().stack
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController = createFetchedResultsController()
        
        addAnnotationAndZoom()
        retrievePhotosOnDisk()
        if hasDataOnDisk() {
            showCollectionCompleteMode()
            refreshCollection()
        } else {
            showCollectionDownloadMode()
            retrievePhotosFromFlikr()
        }
    }
}

// MARK: - Data, Logic

extension PhotoAlbumViewController {
    
    func createFetchedResultsController() -> NSFetchedResultsController<NSFetchRequestResult>? {
        
        let context = coredataStack.context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin = %@", pin!)
        fetchRequest.fetchLimit = 100
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: true)]
        
        return NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: fetchRequest,
                                                                managedObjectContext: context,
                                                                sectionNameKeyPath: nil, cacheName: nil)
    }
    
    
    func addAnnotationAndZoom(){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates!
        mapView.addAnnotation(annotation)
        
        self.mapView.region = region!
        self.mapView.centerCoordinate = coordinates!
    }
    
    func retrievePhotosOnDisk() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e.description)\n\(fetchedResultsController?.description)")
            }
        }
    }
    
    func hasDataOnDisk() -> Bool {
        
        guard let sections = fetchedResultsController?.sections else {
            return false
        }
        
        guard sections.count > 0 else {
            return false
        }
        
        return sections[0].numberOfObjects > 0
    }
    
    
    func handleResponseFromFlikr(_ pictures : [FLKRPicture]?, _ errorMessage : String?){
        
        guard errorMessage == nil else {
            // Error
            return
        }
        
        guard let pictures = pictures else {
            // Error
            return
        }
        
        if pictures.count > 0 {
            // Has pictures, save pictures to db, loads screen 
            // and starts download.
            showCollectionCompleteMode()
            savePicturesOnDisk(pictures)
            retrievePhotosOnDisk()
            refreshCollection()
        } else {
            // No pictures, show proper screen.
            showNoPicturesMode()
        }
    }
    
    func retrievePhotosFromFlikr() {
        
        guard let coordinates = coordinates else {
            // Invalid coordinates
            return
        }
        
        server.retrievePictureList(coordinates: coordinates) { (pictures, errorMessage) in
            self.handleResponseFromFlikr(pictures, errorMessage)
        }
    }
    
    func refreshCollection(){
        self.collectionView.reloadData()
    }
    
    func savePicturesOnDisk(_ pictures : [FLKRPicture]){
    
        let context = coredataStack.context
        
        // TODO: Delete previous data
        
        pictures.forEach { (pic) in
            let entity = Photo(context: context)
            entity.dateAdded = NSDate()
            entity.imageData = nil
            entity.pin = pin!
            entity.url = pic.url
            // TODO: add key to pic. from flickr
            
            coredataStack.save()
        }
    }
    
}

// MARK: - UI Modes

extension PhotoAlbumViewController {
    
    func showNoPicturesMode (){
        collectionView.isHidden = true
        noImagesLabel.isHidden = false
        newCollectionButton.isEnabled = true
    }
    
    func showCollectionDownloadMode(){
        collectionView.isHidden = false
        noImagesLabel.isHidden = true
        newCollectionButton.isEnabled = false
    }
    
    func showCollectionCompleteMode(){
        collectionView.isHidden = false
        noImagesLabel.isHidden = true
        newCollectionButton.isEnabled = true
    }
}


// MARK: - Events

extension PhotoAlbumViewController {
    
    @IBAction func didClickOnNewCollectionButton(_ sender: Any) {
        print("click on new collection")
    }

}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate

extension PhotoAlbumViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let sections = fetchedResultsController?.sections else {
            return 0
        }
        
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let sections = fetchedResultsController?.sections else {
            return 0
        }
        
        return sections[section].numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath) as! PhotoAlbumViewCell
        let photo = fetchedResultsController!.object(at: indexPath) as! Photo
        
        // TODO: Check this
        
//        if let data = photo.imageData as Data? {
//            cell.updatePicture(image: UIImage(data: data)!)
//        } else {
//            cell.startLoading()
//            downloadPictureForPhoto(photo, indexPath: indexPath)
//        }
        
        return cell
    }
}
