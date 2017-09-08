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

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    var pinList : [Pin]?
    let coredataStack = AppDelegate.sharedInstance().stack
    var selectedPin : Pin?
    var selectedCoordinates : CLLocationCoordinate2D?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSavedCoordinates()
        retrievePinsWithCurrentLocation()
    }
    
    func loadSavedCoordinates(){
        if let settings = MapSettingsManager.loadMapSettings() {
            mapView.region = settings.region
        }
    }
    
    func saveCoordinatesPreferences(){
        let settings = MapSettings(region: mapView.region)
        MapSettingsManager.saveMapSettings(settings)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveCoordinatesPreferences()
    }
    
    @IBAction func didLongPressOnMap(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            let touchPoint = sender.location(in: mapView)
            let coordinates =  mapView.convert(touchPoint, toCoordinateFrom: mapView)
            addAnnotationWithCoordinates(coordinates)
        }
    }
    
    // MARK: - Navigation
    
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
    
    // MARK: - Annotations
    
    func addAnnotationWithCoordinates(_ coordinates : CLLocationCoordinate2D){
        
        // Create and save entity
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
        newPin.pinTintColor = MKPinAnnotationView.greenPinColor()
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
    
    func goToPhotoAlbumWithCoodinates(_ coordinates : CLLocationCoordinate2D, pin: Pin){
        selectedCoordinates = coordinates
        selectedPin = pin
        performSegue(withIdentifier: Constants.Segue.ShowAlbum, sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deselectAnnotations()
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
            print("Could not fetch. \(error), \(error.userInfo)")
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

class PinAnnotation : MKPointAnnotation {
    var pin : Pin?
}

extension MapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        retrievePinsWithCurrentLocation()
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = loadOrCreateAnnotation(mapView: mapView, annotation: annotation)
        updateAnnotationPin(annotation: annotation, pinView: pinView!)
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            let pin = (view.annotation as! PinAnnotation).pin!
            goToPhotoAlbumWithCoodinates(annotation.coordinate, pin:pin)
        }
    }
}
