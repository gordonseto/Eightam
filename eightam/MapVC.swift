//
//  MapVC.swift
//  eightam
//
//  Created by Gordon Seto on 2016-08-25.
//  Copyright © 2016 gordonseto. All rights reserved.
//

import UIKit
import MapKit
import GoogleMaps

class MapVC: UIViewController, MKMapViewDelegate, UIGestureRecognizerDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var location: CLLocationCoordinate2D!
    var pin: MKPointAnnotation!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        showGoogleAutoComplete()
        
        mapView.delegate = self
        
        let panRec = UIPanGestureRecognizer(target: self, action: "onMapDragged:")
        panRec.delegate = self
        mapView.addGestureRecognizer(panRec)
    }

    func showGoogleAutoComplete(){
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.presentViewController(autocompleteController, animated: true, completion: nil)
    }
    
    func centerMapOnLocation(place: GMSPlace){
        location = place.coordinate
        
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location, SEARCH_RADIUS * 1000, SEARCH_RADIUS * 1000)
        mapView.setRegion(coordinateRegion, animated: false)
        
        setMapPin(location)
    }
    
    func setMapPin(location: CLLocationCoordinate2D){
        print("pin called")
        if let pin = pin {
            mapView.removeAnnotation(pin)
        }
        pin = MKPointAnnotation()
        pin.coordinate = location
        mapView.addAnnotation(pin)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        let annView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        annView.pinTintColor = BLUE_COLOR
        return annView
    }
    
    func onMapDragged(gestureRecognizer: UIGestureRecognizer) {
        print("wat")
        let location = mapView.centerCoordinate
        setMapPin(location)
    }
    
    @IBAction func onBackButtonPressed(sender: AnyObject) {
        if let navController = self.navigationController {
            navController.popViewControllerAnimated(true)
        }
    }

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension MapVC: GMSAutocompleteViewControllerDelegate {
    func viewController(viewController: GMSAutocompleteViewController, didAutocompleteWithPlace place: GMSPlace) {
        centerMapOnLocation(place)
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    func viewController(viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: NSError) {
        print("Error: ", error.description)
    }
    
    func wasCancelled(viewController: GMSAutocompleteViewController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}