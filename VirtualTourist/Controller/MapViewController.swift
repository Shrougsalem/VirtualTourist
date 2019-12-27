//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Shroog Salem on 24/12/2019.
//  Copyright © 2019 Udacity. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    //MARK: IBOutlet
    @IBOutlet weak var mapView: MKMapView!
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadPins()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        for pin in mapView.selectedAnnotations {
            //to deselect and hide its callout view
            mapView.deselectAnnotation(pin, animated: false)
        }
    }
    //MARK: IBActions
    //Help message for the user on how to use the app
    @IBAction func helpTutorial(_ sender: Any) {
        alert(title: "How to use it!", message: "Tap, Hold & Release to drop a new pin on the map. \n Have fun browsing the pictures from each location! 🌏♥️")
    }
    //To remove all pins annotations from the map view
    @IBAction func clearAll(_ sender: Any) {
        let alert = UIAlertController(title: "This Will Delete All Your Travel Locations. \n Would you like to continue?", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete All", style: .destructive, handler: { (action) in
            self.showSpinner()
            self.deleteAllPins()
            self.removeSpinner()
        }))
        present(alert, animated: true, completion: nil)
    }
    //To drop a new pin after tap & hold gesture
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizer.State.began {
            let location = sender.location(in: mapView)
            let coordinate = self.mapView.convert(location, toCoordinateFrom: mapView)
            let pin = DataController.savePin(longitude: coordinate.longitude, latitude: coordinate.latitude)
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinates
            mapView.addAnnotation(annotation)
            DataController.saveContext()
        }
    }
    
    fileprivate func deleteAllPins() {
        for pin in DataController.getPins() {
            DataController.deletePin(pin)
        }
        let allAnnotation = self.mapView.annotations
        self.mapView.removeAnnotations(allAnnotation)
        DataController.saveContext()
    }
    //MARK: Load/Fetch All Pins
    func loadPins(){
        let pins = DataController.getPins()
        
        for pin in pins {
            if mapView.annotations.contains(where: { pin.checkEquivalentCoordinates(coordinate: $0.coordinate) }) { continue }
            let annotation = MKPointAnnotation()
            annotation.coordinate = pin.coordinates
            mapView.addAnnotation(annotation)
        }
    }
    

    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoAlbum" {
            let photoAlbumVC = segue.destination as! PhotosCollectionViewController
            photoAlbumVC.pin = sender as! Pin
        }
    }
    
}
    extension MapViewController: MKMapViewDelegate{
        
    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        debugPrint("a pin is selected")
        let pin = DataController.getPins().filter {
            $0.checkEquivalentCoordinates(coordinate: view.annotation!.coordinate)
            }.first
       performSegue(withIdentifier: "toPhotoAlbum", sender: pin)
    }
    
}
