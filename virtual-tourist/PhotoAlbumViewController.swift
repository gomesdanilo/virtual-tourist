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
        
        if let pin = pin {
            print("Photo album for pin with coordinates \(pin.longitude),\(pin.latitude)")
        }
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
    
    func deleteAllPictures(){
        
        let context = coredataStack.context
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Photo")
        fetchRequest.includesPropertyValues = false // only fetch the managedObjectID
        
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
    
    
    func handleResponseFromFlikr(_ response : FLKRResponse){
        
        guard response.success else {
            UIUtil.showErrorMessage(response.errorMessage!, viewController: self)
            return
        }
        
        // Removes all pictures from DB, to replace with new set.
        deleteAllPictures()
        
        guard let pictures = response.pictures else {
            UIUtil.showErrorMessage("Failed to retrieve data from flickr.", viewController: self)
            return
        }
        
        guard let pin = pin else {
            // Invalid pin
            return
        }
        
        // Updates current page data.
        pin.page = response.page
        pin.numberOfPages = response.numberOfPages
        coredataStack.save()
        
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
        
        
        server.retrievePictureList(pin: pin) { (response) in
            self.handleResponseFromFlikr(response)
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
