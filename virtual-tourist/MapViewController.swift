//
//  MapViewController.swift
//  virtual-tourist
//
//  Created by Danilo Gomes on 07/09/2017.
//  Copyright © 2017 Danilo Gomes. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    var selectedCoordinates : CLLocationCoordinate2D?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSavedCoordinates()
    }
    
    func loadSavedCoordinates(){
        if let settings = MapSettingsManager.loadMapSettings() {
            mapView.region = settings.region
        }
    }
    
    func saveCoordinates(){
        let settings = MapSettings(region: mapView.region)
        MapSettingsManager.saveMapSettings(settings)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        saveCoordinates()
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
            }
        }
    }
    
    // MARK: - Annotations
    
    func addAnnotationWithCoordinates(_ coordinates : CLLocationCoordinate2D){
        let annotation = MKPointAnnotation()
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
    
    func goToPhotoAlbumWithCoodinates(_ coordinates : CLLocationCoordinate2D){
        selectedCoordinates = coordinates
        performSegue(withIdentifier: Constants.Segue.ShowAlbum, sender: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deselectAnnotations()
    }
    
    func deselectAnnotations(){
        let selected = mapView.selectedAnnotations
        selected.forEach { (annotation) in
            mapView.deselectAnnotation(annotation, animated: false)
        }
    }
}


extension MapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let pinView = loadOrCreateAnnotation(mapView: mapView, annotation: annotation)
        updateAnnotationPin(annotation: annotation, pinView: pinView!)
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation {
            goToPhotoAlbumWithCoodinates(annotation.coordinate)
        }
    }
}
