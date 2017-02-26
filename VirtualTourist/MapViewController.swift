//
//  MapViewController.swift
//  VirtualTourist
//
//  Created by Dandre Ealy on 2/25/17.
//  Copyright © 2017 Dandre Ealy. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import SafariServices


class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var fetchedResultsController:NSFetchedResultsController<Pin>!
  
    let appDelegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        let mapTouched = UILongPressGestureRecognizer(target: self, action: #selector(MapViewController.mapTouched(gestureRecognizer:)))
        mapView.addGestureRecognizer(mapTouched)
    }
    
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(true)
            
            fectchPins()
    }
    
    
    func mapTouched(gestureRecognizer:UIGestureRecognizer) {
        if gestureRecognizer.state == .began {
            let touchPoint = gestureRecognizer.location(in: mapView)
            let pinDropped = MKPointAnnotation()
            let newCoordinates = mapView.convert(touchPoint, toCoordinateFrom: mapView)
            pinDropped.coordinate = newCoordinates
            mapView.addAnnotation(pinDropped)
            
            print("Pin Drop")
            savePin(Float(pinDropped.coordinate.latitude), long: Float(pinDropped.coordinate.longitude))
            
            FlickrClient.sharedInstance().getImages("https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=1201bff4632c3631ae68d58d6bce474c&lat=\(pinDropped.coordinate.latitude)&lon=\(pinDropped.coordinate.longitude)&per_page=20&format=json&nojsoncallback=1")
            
        }
    }
    
    func savePin(_ lat:Float, long:Float) {
        
        let managedContext = appDelegate?.persistentContainer.viewContext
        let pin = Pin(entity: Pin.entity(), insertInto: managedContext)
        pin.latitude = lat
        pin.longitude = long
        
        do {
            try managedContext?.save()
        } catch let error as NSError {
            print("Could not save \(error.userInfo)")
        }
    }
    

    func fectchPins() {
        
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        
        let sort = NSSortDescriptor(key: "latitude", ascending: true, selector: #selector(NSString.localizedStandardCompare(_:)))
        fetchRequest.sortDescriptors = [sort]
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: (appDelegate?.persistentContainer.viewContext)!, sectionNameKeyPath: nil, cacheName: nil)
        
        do {
            try fetchedResultsController.performFetch()
            let results = fetchedResultsController.fetchedObjects
            var pins = [MKPointAnnotation]()
            for pin in results! {
                let annotation = MKPointAnnotation()
                annotation.coordinate.latitude = CLLocationDegrees(pin.latitude)
                annotation.coordinate.longitude = CLLocationDegrees(pin.longitude)
                pins.append(annotation)
                mapView.addAnnotation(annotation)
            }
            
        } catch let error as NSError {
            print("Error fecthing pins \(error.localizedDescription)")
        }
    }
    
}

extension MapViewController {
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let photoVC = storyboard?.instantiateViewController(withIdentifier: "photoVC") as! PhotoViewController
        photoVC.currentCoordinate = (view.annotation?.coordinate)!
        navigationController?.pushViewController(photoVC, animated: true)
        
    }
    
}
