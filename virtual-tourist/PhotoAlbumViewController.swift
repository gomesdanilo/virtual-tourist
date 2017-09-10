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

    enum AlbumUIMode {
        case NoPictures
        case DownloadMode
        case CompleteMode
    }
    
    
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
    var fetchedResultsController : NSFetchedResultsController<NSManagedObject>?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController = createFetchedResultsController()
        
        if let pin = pin {
            print("Photo album for pin with coordinates \(pin.longitude),\(pin.latitude)")
        }
        addAnnotationAndZoom()
        retrievePhotosOnDisk()
        if hasDataOnDisk() {
            updateUIMode(.CompleteMode)
            refreshCollection()
        } else {
            updateUIMode(.DownloadMode)
            retrievePhotosFromFlikr()
        }
    }
}

// MARK: - Data, Logic

extension PhotoAlbumViewController {
    
    func deleteAllPictures(){
        
        let context = coredataStack.context
        let fetchRequest = createFetchResquest()
        // only fetch the managedObjectID
        fetchRequest.includesPropertyValues = false
        
        do {
            let results = try context.fetch(fetchRequest)
            
            // Call on block?
            
            results.forEach({ (entry) in
                context.delete(entry)
            })
            
            coredataStack.save()
            
            
        } catch {
            // Error
        }
    }
    
    func createFetchResquest() -> NSFetchRequest<NSManagedObject>{
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin = %@", pin!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: true)]
        return fetchRequest
    }
    
    func createFetchedResultsController() -> NSFetchedResultsController<NSManagedObject>? {
        
        let context = coredataStack.context
        let fetchRequest = createFetchResquest()
        return NSFetchedResultsController<NSManagedObject>(fetchRequest: fetchRequest,
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
                let message = "Error while trying to perform a search: \n\(e.description)\n\(fc.description)"
                UIUtil.showErrorMessage(message, viewController: self)
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
    
    
    
    func retrievePhotosFromFlikr() {
        
        guard let pin = pin else {
            // Invalid pin
            return
        }
        
        // Calculates page number.
        if pin.page == 0 || pin.numberOfPages == 0 {
            pin.page = 1
            pin.numberOfPages = 1
        }
        else {
            // Goes to next page. If last page is hit, then restarts the cycle.
            pin.page = (pin.page + 1) % pin.numberOfPages
        }
        // Updates DB.
        coredataStack.save()
        
        updateUIMode(.DownloadMode)
        
        server.retrievePictureList(pin: pin) { (response) in
            guard response.success else {
                UIUtil.showErrorMessage(response.errorMessage!, viewController: self)
                return
            }
            
            // Removes all pictures from DB linked to same pin, to replace with new set.
            self.deleteAllPictures()
            
            guard let pictures = response.pictures else {
                UIUtil.showErrorMessage("Failed to retrieve data from flickr.", viewController: self)
                return
            }
            
            // Updates current page data.
            pin.page = response.page
            pin.numberOfPages = response.numberOfPages
            self.coredataStack.save()
            
            if pictures.count > 0 {
                // Has pictures, save pictures to db, loads screen
                // and starts download.
                self.updateUIMode(.CompleteMode)
                self.savePicturesOnDisk(pictures)
                self.retrievePhotosOnDisk()
                self.refreshCollection()
            } else {
                // No pictures, show proper screen.
                self.updateUIMode(.NoPictures)
            }
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
            
            coredataStack.save()
        }
    }
    
    func downloadImage(_ photo: Photo, indexPath : IndexPath){
        
        FLKRClient.sharedInstance().downloadPicture(url: photo.url!) { (data, errorMessage) in
            
            guard let data = data else {
                // Error
                return
            }
            
            photo.imageData = data as NSData
            self.coredataStack.save()
            self.collectionView?.reloadItems(at: [indexPath])
        }
    }
    
    func deletePhoto(_ photo: Photo){
        let context = coredataStack.context
        context.delete(photo)
        coredataStack.save()
    }
    
}

// MARK: - UI Modes

extension PhotoAlbumViewController {
    
    func updateUIMode(_ mode : AlbumUIMode){
        
        switch mode {
        case .NoPictures:
            collectionView.isHidden = true
            noImagesLabel.isHidden = false
            newCollectionButton.isEnabled = true
            print("no pictures mode")
        case .DownloadMode:
            collectionView.isHidden = false
            noImagesLabel.isHidden = true
            newCollectionButton.isEnabled = false
            print("download mode")
        case .CompleteMode:
            collectionView.isHidden = false
            noImagesLabel.isHidden = true
            newCollectionButton.isEnabled = true
            print("complete mode")
        }
    }
}


// MARK: - Events

extension PhotoAlbumViewController {
    
    @IBAction func didClickOnNewCollectionButton(_ sender: Any) {
        retrievePhotosFromFlikr()
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
        
        if let data = photo.imageData as Data? {
            cell.updatePicture(image: UIImage(data: data)!)
        } else {
            cell.startLoading()
            downloadImage(photo, indexPath: indexPath)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        collectionView.performBatchUpdates({ 
            let photo = self.fetchedResultsController!.object(at: indexPath) as! Photo
            self.deletePhoto(photo)
            collectionView.deleteItems(at: [indexPath])
            self.retrievePhotosOnDisk()
        }, completion: nil)
    }
}
