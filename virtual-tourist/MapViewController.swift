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
    
    var selectedAnnotation : MKAnnotation?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        if Constants.Segue.showAlbum == segue.identifier {
            if let vc = segue.destination as? PhotoAlbumViewController {
                // Add code here to send to the next vc
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
    
    func populateAnnotationPin(annotation: MKAnnotation, pinView : MKAnnotationView){
        
        pinView.annotation = annotation
        
        if let selected = selectedAnnotation {
            if selected.isEqual(annotation) {
                pinView.tintColor = MKPinAnnotationView.redPinColor()
                return
            }
        }
        
        pinView.tintColor = MKPinAnnotationView.greenPinColor()
    }
}


extension MapViewController : MKMapViewDelegate {

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("Region changed")
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseKey = Constants.reuseAnnotationIdentifier
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseKey)
        if pinView == nil {
            pinView = buildNewAnnotationPin(annotation: annotation)
        }
        populateAnnotationPin(annotation: annotation, pinView: pinView!)
        
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        print("Pin selected")
        selectedAnnotation = view.annotation
    }
}
