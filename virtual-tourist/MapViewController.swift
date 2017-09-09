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
    var pinList : [Pin]?
    let coredataStack = AppDelegate.sharedInstance().stack
    var selectedPin : Pin?
    var selectedCoordinates : CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSavedCoordinates()
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
}

// MARK - Navigation

extension MapViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if Constants.Segue.ShowAlbum == segue.identifier {
            if let vc = segue.destination as? PhotoAlbumViewController,
                let coordinates = selectedCoordinates {
                vc.coordinates = coordinates
                vc.region = mapView.region
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
    
    func addAnnotationWithCoordinates(_ coordinates : CLLocationCoordinate2D){
        
        // Creates and saves entity, saving in the context.
        let context = coredataStack.context
        let newPin = Pin(context: context)
        newPin.latitude = coordinates.latitude
        newPin.longitude = coordinates.longitude
        coredataStack.save()
        
        // Create annotation on map
        let annotation = PinAnnotation()
        annotation.pin = newPin
        annotation.coordinate = coordinates
        mapView.addAnnotation(annotation)
    }
    
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
        if sender.state == .began {
            // Converts touch location to gps coordinates
            let touchPoint = sender.location(in: mapView)
            let coordinates =  mapView.convert(touchPoint, toCoordinateFrom: mapView)
            
            // Add annotation to map
            addAnnotationWithCoordinates(coordinates)
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
