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

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var noImagesLabel: UILabel!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
    let server = FLKRClient.sharedInstance()
    var pin : Pin?
    var coordinates : CLLocationCoordinate2D?
    var region : MKCoordinateRegion?
    let coredataStack = AppDelegate.sharedInstance().stack
    var fetchedResultsController : NSFetchedResultsController<NSFetchRequestResult>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addAnnotationAndZoom()
        hideGridAndLabel()
        retrievePictureListFromFlikr()
        
        
        let context = coredataStack.context
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin = %@", pin!)
        fetchRequest.fetchLimit = 100
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateAdded", ascending: true)]
        
        
//        do {
//            let results = try context.fetch(fetchRequest)
//        } catch {
//            print(error)
//        }
//        
//
        fetchedResultsController = NSFetchedResultsController<NSFetchRequestResult>(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        
        executeSearch()
        
        
        if(hasData()){
            showPicturesGrid()
            collectionView.reloadData()
        }
        else {
            // Request data.
            retrievePictureListFromFlikr()
        }
    }
    
    func hasData() -> Bool {
        guard let fc = fetchedResultsController else {
            return false
        }
        
        guard let sections = fc.sections else {
            return false
        }
        
        guard sections.count > 0 else {
            return false
        }
        
        return sections[0].numberOfObjects > 0
    }
    
    func addAnnotationAndZoom(){
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinates!
        mapView.addAnnotation(annotation)
        
        self.mapView.region = region!
        self.mapView.centerCoordinate = coordinates!
    }
    
    func executeSearch() {
        if let fc = fetchedResultsController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e.description)\n\(fetchedResultsController?.description)")
            }
        }
    }
    
    @IBAction func didClickOnNewCollectionButton(_ sender: Any) {
        
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
        
//        if let pics = pictures {
//            let pic = pics[indexPath.row]
//            if let url = pic.url {
//                FLKRClient.sharedInstance().downloadPicture(url: url, completionHandler: { (url, error) in
//                    
//                    guard let url = url else {
//                        return
//                    }
//                    
//                    let image = self.imageDataFromDisk(url: url)
//                    self.imageData![indexPath.row] = image
//                    self.collectionView?.reloadItems(at: [indexPath])
//                })
//            }
//        }
    }
    
    func imageForCell(indexPath: IndexPath) -> UIImage?{
//        if let pics = imageData {
//            let pic = pics[indexPath.row]
//            return pic
//        }
        return nil
    }
    
    
    
    // MARK: Visibility and mode code
    
    func enableNoPicturesMode(){
        // Error / No pictures
        self.showNoPicturesLabel()
        self.collectionView?.reloadData()
    }
    
    func loadScreenWithPictures(_ pictures : [FLKRPicture]){
        
        let context = coredataStack.context
        
        pictures.forEach { (pic) in
            let entity = Photo(context: context)
            entity.dateAdded = NSDate()
            entity.imageData = nil
            entity.pin = pin!
            entity.url = pic.url
            // TODO: add key to pic.
            
            coredataStack.save()
        }
        
        self.showPicturesGrid()
        executeSearch()
        self.collectionView?.reloadData()
    }
    
    
    func hideGridAndLabel(){
        self.collectionView.isHidden = true
        self.noImagesLabel.isHidden = true
    }
    
    func showPicturesGrid(){
        self.collectionView.isHidden = false
        self.noImagesLabel.isHidden = true
    }
    
    func showNoPicturesLabel(){
        self.collectionView.isHidden = true
        self.noImagesLabel.isHidden = false
    }
    
    
    
}

extension PhotoAlbumViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let fc = fetchedResultsController else {
            return 0
        }
        
        guard let sections = fc.sections else {
            return 0
        }
        
        return sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        guard let fc = fetchedResultsController else {
            return 0
        }
        
        guard let sections = fc.sections else {
            return 0
        }
        
        return sections[section].numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photo", for: indexPath) as! PhotoAlbumViewCell
        
        let photo = fetchedResultsController!.object(at: indexPath) as! Photo
        print("rendering phoro: ", photo.url!)
//        
//        
//        let image = imageForCell(indexPath: indexPath)
//        if(image != nil){
//            cell.updatePicture(image: image!)
//        } else {
//            cell.startLoading()
//            downloadPicture(indexPath: indexPath)
//        }
//        
        return cell
    }
}
