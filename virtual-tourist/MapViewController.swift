//
//  MapViewController.swift
//  virtual-tourist
//
//  Created by Danilo Gomes on 07/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import MapKit
import CoreData

// MARK: - PinAnnotation

class PinAnnotation : MKPointAnnotation {
    var pin : Pin?
}

// MARK: - MapViewController

class MapViewController: UIViewController {

    // UI
    @IBOutlet weak var mapView: MKMapView!
    
    // Data
    var preferencesLoaded = false
    var pinList : [Pin]?
    let coredataStack = AppDelegate.sharedInstance().stack
    var selectedPin : Pin?
    var selectedCoordinates : CLLocationCoordinate2D?
    
    var pinOnCreation : PinAnnotation?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        retrievePinsWithCurrentLocation()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveCoordinatesPreferences()
    }
   
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deselectAnnotations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Apparently there is bug if we call this with viewDidLoad.
        // https://stackoverflow.com/questions/4221200/mkmapview-setregion-isnt-constant
        if !preferencesLoaded {
            preferencesLoaded = true
            loadSavedCoordinates()
        }
    }
}

// MARK - Navigation

extension MapViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if Constants.Segue.ShowAlbum == segue.identifier {
            if let vc = segue.destination as? PhotoAlbumViewController,
                let coordinates = selectedCoordinates {
                vc.coordinates = coordinates
                
                let span = MKCoordinateSpanMake(0, mapView.region.span.longitudeDelta)
                vc.region = MKCoordinateRegionMake(coordinates,span)
                vc.pin = selectedPin
            }
        }
    }
    
    func goToPhotoAlbumWithCoodinates(_ coordinates : CLLocationCoordinate2D, pin: Pin){
        selectedCoordinates = coordinates
        selectedPin = pin
        performSegue(withIdentifier: Constants.Segue.ShowAlbum, sender: self)
    }
    

}

// MARK - Annotations

extension MapViewController {
  
    
    func buildNewAnnotationPin(annotation: MKAnnotation) -> MKAnnotationView {
        let reuseId = Constants.reuseAnnotationIdentifier
        let newPin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
        newPin.pinTintColor = MKPinAnnotationView.redPinColor()
        newPin.canShowCallout = false
        return newPin
    }
    
    func loadOrCreateAnnotation(mapView: MKMapView, annotation: MKAnnotation) -> MKAnnotationView?{
        let reuseKey = Constants.reuseAnnotationIdentifier
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseKey)
        if pinView == nil {
            pinView = buildNewAnnotationPin(annotation: annotation)
        }
        return pinView
    }
    
    func updateAnnotationPin(annotation: MKAnnotation, pinView : MKAnnotationView){
        pinView.annotation = annotation
    }
    
    func deleteAnnotations(){
        mapView.removeAnnotations(mapView.annotations)
    }
    
    func deselectAnnotations(){
        let selected = mapView.selectedAnnotations
        selected.forEach { (annotation) in
            mapView.deselectAnnotation(annotation, animated: false)
        }
    }
    
    func createAnnotationWithPin(_ pin : Pin) -> PinAnnotation {
        
        let annotation = PinAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        annotation.pin = pin
        return annotation
    }
    
    func retrievePinsWithCurrentLocation(){
        
        let box = CoordinatesBoundaryBox(region: mapView.region)
        let managedContext = coredataStack.context
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Pin")
        fetchRequest.fetchLimit = 100
        fetchRequest.predicate = NSPredicate(format:
            " longitude >= %lf AND latitude >= %lf AND longitude <= %lf AND latitude <= %lf ",
                                             box.minLongitude, box.minLatitude,
                                             box.maxLongitude, box.maxLatitude)
        
        do {
            pinList = try managedContext.fetch(fetchRequest) as? [Pin]
        } catch let error as NSError {
            let message = "Failed to retrieve pins. \(error), \(error.userInfo)"
            UIUtil.showErrorMessage(message, viewController: self)
            pinList = nil
        }
        
        deleteAnnotations()
        
        guard let pinList = pinList else {
            // Invalid annotation
            return
        }
        
        pinList.forEach { (pin) in
            mapView.addAnnotation(createAnnotationWithPin(pin))
        }
    }
}

// MARK - Events

extension MapViewController {

    @IBAction func didLongPressOnMap(_ sender: UILongPressGestureRecognizer) {
        
        // Converts touch location to gps coordinates
        let touchPoint = sender.location(in: mapView)
        let coordinates =  mapView.convert(touchPoint, toCoordinateFrom: mapView)

        
        switch sender.state {
        case .began:
            // Create annotation on map
            pinOnCreation = PinAnnotation()
            pinOnCreation?.coordinate = coordinates
            mapView.addAnnotation(pinOnCreation!)
            
            
        case .changed:
            // Updates coordinates
            pinOnCreation?.coordinate = coordinates
           
            
        case .ended:
            if let pinOnCreation = pinOnCreation {
                
                // Updates coordinates
                pinOnCreation.coordinate = coordinates
                
                // Creates and saves entity, saving in the context.
                let context = coredataStack.context
                let newPin = Pin(context: context)
                newPin.latitude = coordinates.latitude
                newPin.longitude = coordinates.longitude
                coredataStack.save()
                
                // Updates reference
                pinOnCreation.pin = newPin
            }
            pinOnCreation = nil
            
        default:
            break
        }
    }
}

// MARK: - Coordinates preferences (load, save, update)

extension MapViewController {
    
    func loadSavedCoordinates(){
        if let settings =  AppDelegate.sharedInstance().mapSettings {
            mapView.region = settings.region
        }
    }
    
    func updateCoordinatesPreferences() {
        let settings = MapSettings(region: mapView.region)
        AppDelegate.sharedInstance().mapSettings = settings
    }
    
    func saveCoordinatesPreferences(){
        updateCoordinatesPreferences()
        AppDelegate.sharedInstance().saveMapSettings()
    }

}

// MARK: - MKMapViewDelegate

extension MapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        updateCoordinatesPreferences()
        retrievePinsWithCurrentLocation()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = loadOrCreateAnnotation(mapView: mapView, annotation: annotation)
        updateAnnotationPin(annotation: annotation, pinView: pinView!)
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? PinAnnotation {
            if let pin = annotation.pin {
                goToPhotoAlbumWithCoodinates(annotation.coordinate, pin:pin)
            }
        }
    }
}
